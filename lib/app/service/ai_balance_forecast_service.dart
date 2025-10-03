import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/viewmodel/settings/settings_viewmodel.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/database/sqllite/sql_lite.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/service/notification_service.dart';

/// IA de previsão de saldo até o fim do mês, com alerta proativo.
class AiBalanceForecastService {
  static final AiBalanceForecastService _instance = AiBalanceForecastService._internal();
  factory AiBalanceForecastService() => _instance;
  AiBalanceForecastService._internal();

  final AuthService _auth = AuthService();
  final NotificationService _notifier = NotificationService();
  final SettingsViewmodel _settings = Modular.get<SettingsViewmodel>();

  /// Roda a previsão e notifica se houver risco (uma vez por dia).
  Future<void> runDailyForecast() async {
    try {
      await _settings.load();
      if (!_settings.notificationsEnabled || !_settings.aiBalanceForecastEnabled) {
        if (kDebugMode) print('🔕 AI Balance Forecast notifications disabled');
        return;
      }
      final userId = _auth.userId;
      if (userId == null) return;

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final guardKey = 'ai_balance_forecast_${now.year}_${now.month}_${now.day}';
      if (prefs.getBool(guardKey) ?? false) return; // evita spam no mesmo dia

      final db = await DB.instance.database;
      final query = CommandSql(db);

      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfMonthMs = startOfMonth.millisecondsSinceEpoch;
      final nowMs = now.millisecondsSinceEpoch;

      // Saldo acumulado até o mês anterior
      final sumBeforeRows = await query.rawQuery(
        'SELECT SUM(Valor) as total FROM movimentacao WHERE IdUsuario = ? AND DataMovimentacao < ?',
        [userId, startOfMonthMs],
      );
      final saldoAteMesAnterior = ((sumBeforeRows.first['total'] as num?) ?? 0).toDouble();

      // Total do mês até agora
      final monthRows = await query.rawQuery(
        'SELECT Valor, IsSaida, DataMovimentacao, IdCategoria FROM movimentacao WHERE IdUsuario = ? AND DataMovimentacao >= ? AND DataMovimentacao <= ?',
        [userId, startOfMonthMs, nowMs],
      );
      double totalMesAteAgora = 0.0;
      double despesasAteAgora = 0.0;
      for (final r in monthRows) {
        final v = (r['Valor'] as num).toDouble();
        totalMesAteAgora += v;
        if ((r['IsSaida'] as int) == 1) {
          despesasAteAgora += v.abs();
        }
      }

      // Média diária de despesas não recorrentes (aproximação: todas as despesas até agora / dias decorridos)
      final daysElapsed = max(1, now.difference(startOfMonth).inDays + 1);
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final remainingDays = max(0, daysInMonth - daysElapsed);
      if (remainingDays == 0) {
        if (kDebugMode) print('ℹ️ Sem dias restantes no mês. Previsão não necessária.');
        return;
      }
      final dailyAvgDespesa = despesasAteAgora / daysElapsed;
      final projDespesaRestante = dailyAvgDespesa * remainingDays;

      // Projeção simples de salário (categoria 8) caso ainda não lançado neste mês
      double projSalario = 0.0;
      final salarioRowsMes = monthRows.where((r) => (r['IsSaida'] as int) == 0 && (r['IdCategoria'] as int?) == 8).toList();
      if (salarioRowsMes.isEmpty && now.day <= 15) {
        final threeYearsAgo = DateTime(now.year - 1, now.month, 1).subtract(const Duration(days: 31 * 2));
        final prevRows = await query.rawQuery(
          'SELECT Valor, DataMovimentacao FROM movimentacao WHERE IdUsuario = ? AND IsSaida = 0 AND IdCategoria = 8 AND DataMovimentacao >= ? ORDER BY DataMovimentacao DESC LIMIT 6',
          [userId, threeYearsAgo.millisecondsSinceEpoch],
        );
        if (prevRows.isNotEmpty) {
          final valores = prevRows.map((r) => (r['Valor'] as num).toDouble().abs()).toList()..sort();
          projSalario = valores[valores.length ~/ 2]; // mediana
        }
      }

      final totalProjetadoMes = totalMesAteAgora - projDespesaRestante + projSalario; // despesas são negativas no saldo líquido
      final saldoPrevistoFimMes = saldoAteMesAnterior + totalProjetadoMes;

      if (kDebugMode) {
        print('📈 Forecast — saldoAnterior: ${saldoAteMesAnterior.toStringAsFixed(2)}');
        print('📈 totalMesAteAgora: ${totalMesAteAgora.toStringAsFixed(2)}');
        print('📈 dailyAvgDespesa: ${dailyAvgDespesa.toStringAsFixed(2)}  remDays=$remainingDays  projDespesaRestante=${projDespesaRestante.toStringAsFixed(2)}');
        print('📈 projSalario: ${projSalario.toStringAsFixed(2)}');
        print('📈 saldoPrevistoFimMes: ${saldoPrevistoFimMes.toStringAsFixed(2)}');
      }

      // Critérios de alerta
      const buffer = 200.0; // colchão mínimo desejável
      if (saldoPrevistoFimMes < 0 || saldoPrevistoFimMes < buffer) {
        final alvo = max(0.0, buffer);
        final deficit = (alvo - saldoPrevistoFimMes).clamp(0.0, double.infinity);
        final ajusteDiario = remainingDays > 0 ? (deficit / remainingDays) : deficit;
        final ajusteStr = _formatCurrency(ajusteDiario);
        final previstoStr = _formatCurrency(saldoPrevistoFimMes);

        final title = saldoPrevistoFimMes < 0
            ? 'Risco de saldo negativo este mês'
            : 'Saldo previsto baixo no fim do mês';
        final body = 'Projeção atual: $previstoStr. Reduzindo cerca de $ajusteStr por dia, você termina dentro da meta.';

        await _notifier.sendSimpleNotification(title: title, body: body);
        await prefs.setBool(guardKey, true);
        if (kDebugMode) print('✅ Alerta de previsão enviado');
      }
    } catch (e) {
      if (kDebugMode) print('❌ AiBalanceForecastService.runDailyForecast erro: $e');
    }
  }

  String _formatCurrency(double v) {
    final s = v.abs().toStringAsFixed(2).replaceAll('.', ',');
    final prefix = v < 0 ? '-R\$ ' : 'R\$ ';
    return '$prefix$s';
  }
}
