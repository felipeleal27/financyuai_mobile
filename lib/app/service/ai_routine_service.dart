import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/viewmodel/settings/settings_viewmodel.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/database/sqllite/sql_lite.dart';
import 'package:neo_financyuai/app/service/notification_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';

/// Detecta rotinas de despesas do usuário e lembra quando algo provavelmente foi esquecido.
/// Sem tarefas em background: executa sob demanda (ex.: no startup do app).
class AiRoutineService {
  static final AiRoutineService _instance = AiRoutineService._internal();
  factory AiRoutineService() => _instance;
  AiRoutineService._internal();

  final NotificationService _notifier = NotificationService();
  final AuthService _auth = AuthService();
  final SettingsViewmodel _settings = Modular.get<SettingsViewmodel>();

  /// Executa a análise leve: identifica possíveis compromissos recorrentes e,
  /// se um deles estiver "atrasado" neste mês, emite um lembrete.
  Future<void> runDailyAnalysis() async {
    try {
      await _settings.load();
      if (!_settings.notificationsEnabled || !_settings.aiRoutineEnabled) {
        if (kDebugMode) print('🔕 AI Routine notifications disabled');
        return;
      }
      final userId = _auth.userId;
      if (userId == null) return; // Precisa do usuário logado para filtrar dados

      final db = await DB.instance.database;
      final query = CommandSql(db);

      // Carrega últimas 12-18 meses de movimentações do usuário para detectar padrões
      final cutoff = DateTime.now().subtract(const Duration(days: 550));
      final rows = await query.rawQuery(
        'SELECT Nome, Valor, IsSaida, DataMovimentacao FROM movimentacao WHERE IdUsuario = ? AND IsSaida = 1 AND DataMovimentacao >= ? ORDER BY DataMovimentacao DESC',
        [userId, cutoff.millisecondsSinceEpoch],
      );

      // Agrupa por "Nome" (favorecido). Heurística simples: normaliza texto.
      final Map<String, List<DateTime>> porFavorecido = {};
      for (final r in rows) {
        final nome = (r['Nome'] as String).trim();
        if (nome.isEmpty) continue;
        final key = _normalizeName(nome);
        final dt = DateTime.fromMillisecondsSinceEpoch(r['DataMovimentacao'] as int);
        porFavorecido.putIfAbsent(key, () => []).add(dt);
      }

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      for (final entry in porFavorecido.entries) {
        final favorecidoKey = entry.key;
        final dates = entry.value..sort(); // crescente

        if (dates.length < 4) continue; // precisa de histórico mínimo

        // Detecta padrões: mensal (todo mês ~ mesmo dia) ou quinzenal (duas vezes/mês)
        final pattern = _detectPattern(dates);
        if (pattern == _Pattern.none) continue;

        // Calcula o(s) dia(s) esperado(s) neste mês
        final expectedDays = _expectedDaysThisMonth(dates, pattern);
        if (expectedDays.isEmpty) continue;

        // Se estamos 10-11 dias após o primeiro esperado e não há lançamento neste mês, lembrar.
        final firstExpected = expectedDays.first;
        const graceDays = 10; // janela que você pediu
        final triggerStart = DateTime(now.year, now.month, firstExpected).add(const Duration(days: graceDays));
        final triggerEnd = triggerStart.add(const Duration(days: 2)); // 2 dias de janela (10-11)

        if (now.isBefore(triggerStart) || now.isAfter(triggerEnd)) continue;

        // Já registrou este favorecido neste mês?
        final existing = rows.any((r) {
          final n = _normalizeName((r['Nome'] as String).trim());
          if (n != favorecidoKey) return false;
          final dt = DateTime.fromMillisecondsSinceEpoch(r['DataMovimentacao'] as int);
          return dt.year == now.year && dt.month == now.month;
        });
        if (existing) continue;

        // Anti-spam: não notificar 2x no mesmo mês
        final guardKey = 'ai_last_notify_${_guardKeyHash(favorecidoKey)}_${now.year}_${now.month}';
        final already = prefs.getBool(guardKey) ?? false;
        if (already) continue;

        // Monta mensagem usando o nome original (des-normalizado: capitaliza)
        final prettyName = _prettifyName(favorecidoKey);
        final title = 'Você já pagou $prettyName?';
        final body = 'Percebemos que ainda não adicionou a despesa para $prettyName este mês. Um lembrete para você não esquecer e evitar transtornos.';

        await _notifier.sendSimpleNotification(title: title, body: body);

        await prefs.setBool(guardKey, true);
        if (kDebugMode) {
          print('🤖 AI lembrete enviado para "$prettyName"');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AiRoutineService.runDailyAnalysis erro: $e');
      }
    }
  }

  String _normalizeName(String name) {
    final n = name.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9áéíóúãõâêîôûç ]', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return n;
  }

  String _prettifyName(String normalized) {
    return normalized.split(' ').map((w) => w.isEmpty ? w : (w[0].toUpperCase() + w.substring(1))).join(' ');
  }

  String _guardKeyHash(String s) {
    // hash leve estável
    return s.codeUnits.fold<int>(0, (a, b) => (a * 131 + b) & 0x7fffffff).toString();
  }

  _Pattern _detectPattern(List<DateTime> dates) {
    // Heurística simples: se a mediana do dia do mês é estável e o desvio é pequeno -> mensal
    final days = dates.map((d) => d.day).toList()..sort();
    if (days.length < 4) return _Pattern.none;

  // mediana não usada diretamente; mantemos apenas para documentação
    final mean = days.reduce((a, b) => a + b) / days.length;
    final variance = days.map((d) => pow(d - mean, 2)).reduce((a, b) => a + b) / days.length;
    final stddev = sqrt(variance);

    if (stddev <= 2.5) {
      return _Pattern.monthly; // ocorre sempre por volta do mesmo dia
    }

    // Quinzenal: detectar presença de dois clusters/médias por mês
    // Simplificado: se há muitos casos no início (<=10) e no fim (>=20) de mês.
    final early = days.where((d) => d <= 10).length;
    final late = days.where((d) => d >= 20).length;
    if (early >= 3 && late >= 3) {
      return _Pattern.semiMonthly;
    }

    return _Pattern.none;
  }

  List<int> _expectedDaysThisMonth(List<DateTime> dates, _Pattern pattern) {
  if (pattern == _Pattern.monthly) {
      final days = dates.map((d) => d.day).toList()..sort();
      final typical = days[days.length ~/ 2]; // mediana
      return [min(28, max(1, typical))];
    }
    if (pattern == _Pattern.semiMonthly) {
      return [5, 25]; // heurística simples (começo/fim do mês)
    }
    return const [];
  }
}

enum _Pattern { none, monthly, semiMonthly }
