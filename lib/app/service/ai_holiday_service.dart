import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/viewmodel/settings/settings_viewmodel.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/database/sqllite/sql_lite.dart';
import 'package:neo_financyuai/app/service/notification_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';

/// IA de feriados e datas comemorativas: prevê gastos e lembra o usuário.
class AiHolidayService {
  static final AiHolidayService _instance = AiHolidayService._internal();
  factory AiHolidayService() => _instance;
  AiHolidayService._internal();

  final NotificationService _notifier = NotificationService();
  final AuthService _auth = AuthService();
  final SettingsViewmodel _settings = Modular.get<SettingsViewmodel>();

  /// Executa diariamente: verifica se há feriado chegando e dispara lembrete.
  Future<void> runDailyAnalysis() async {
    try {
      await _settings.load();
      if (!_settings.notificationsEnabled || !_settings.aiHolidayEnabled) {
        if (kDebugMode) print('🔕 AI Holiday notifications disabled');
        return;
      }
      final userId = _auth.userId;
      if (userId == null) return;

      final now = DateTime.now();
      final upcoming = _upcomingHolidays(now);
      final prefs = await SharedPreferences.getInstance();

  for (final h in upcoming.entries) {
        // Janelas de aviso por feriado (padrões razoáveis)
  final daysBefore = _daysBeforeFor(h.key);
  final windowStart = h.value.subtract(Duration(days: daysBefore));
  final windowEnd = h.value; // até o dia do feriado
        if (now.isBefore(windowStart) || now.isAfter(windowEnd)) continue;

        final guardKey = 'ai_holiday_${h.key}_${now.year}';
        if (prefs.getBool(guardKey) ?? false) continue; // um por ano por feriado

        // Estima gasto baseado em histórico próximo da data em anos anteriores
        final estimate = await _estimateSpendAround(userId, h.value);
        final formatted = estimate != null ? _formatCurrency(estimate) : null;
        final title = _titleFor(h.key);
        final body = formatted == null
            ? 'Estamos chegando em ${_label(h.key)}. É comum gastar um pouco mais nessa época. Quer se planejar?'
            : 'Estamos chegando em ${_label(h.key)}. No seu histórico, você costuma gastar cerca de $formatted. Que tal se planejar?';

        await _notifier.sendSimpleNotification(title: title, body: body);
        await prefs.setBool(guardKey, true);

        if (kDebugMode) {
          print('🎉 Lembrete de feriado enviado: ${h.key}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AiHolidayService.runDailyAnalysis erro: $e');
      }
    }
  }

  Map<String, DateTime> _upcomingHolidays(DateTime now) {
    final year = now.year;
    final holidays = <String, DateTime>{
      'natal': DateTime(year, 12, 25),
      'anonovo': DateTime(year + 1, 1, 1), // próximo 1º de janeiro
      'pascoa': _easterDate(year),
      'carnaval': _carnivalDate(year),
    };

    // Se já passou o feriado neste ano, cálculo para o próximo
    holidays.updateAll((k, v) {
      if (!v.isAfter(now)) {
        if (k == 'anonovo') {
          return DateTime(year + 1, 1, 1);
        }
        if (k == 'pascoa') {
          return _easterDate(year + 1);
        }
        if (k == 'carnaval') {
          return _carnivalDate(year + 1);
        }
        if (k == 'natal') {
          return DateTime(year + 1, 12, 25);
        }
      }
      return v;
    });

    // birthdays: Placeholder — futura integração com agenda/contatos (opt-in)
    return holidays;
  }

  int _daysBeforeFor(String key) {
    switch (key) {
      case 'natal':
        return 10; // compras e presentes
      case 'anonovo':
        return 5; // ceia/viagem
      case 'carnaval':
        return 14; // fantasia/viagem/ingressos
      case 'pascoa':
        return 10; // ovos de páscoa/presentes
      default:
        return 7;
    }
  }

  String _titleFor(String key) {
    switch (key) {
      case 'natal':
        return 'Natal chegando';
      case 'anonovo':
        return 'Ano Novo chegando';
      case 'carnaval':
        return 'Carnaval chegando';
      case 'pascoa':
        return 'Páscoa chegando';
      default:
        return 'Data especial chegando';
    }
  }

  String _label(String key) {
    switch (key) {
      case 'natal':
        return 'Natal';
      case 'anonovo':
        return 'Ano Novo';
      case 'carnaval':
        return 'Carnaval';
      case 'pascoa':
        return 'Páscoa';
      default:
        return 'uma data especial';
    }
  }

  Future<double?> _estimateSpendAround(String userId, DateTime target) async {
    try {
      final db = await DB.instance.database;
      final query = CommandSql(db);
      final start = DateTime(target.year - 3, target.month, target.day).subtract(const Duration(days: 7));
      final end = DateTime(target.year - 1, target.month, target.day).add(const Duration(days: 7));

      final rows = await query.rawQuery(
        'SELECT Valor, IsSaida, DataMovimentacao FROM movimentacao WHERE IdUsuario = ? AND IsSaida = 1 AND DataMovimentacao BETWEEN ? AND ? ORDER BY DataMovimentacao DESC',
        [userId, start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      );

      if (rows.isEmpty) return null;
      final valores = rows.map((r) => (r['Valor'] as num).toDouble()).toList();
      valores.sort();
      final median = valores[valores.length ~/ 2];
      // guarda-chuva: arredonda para duas casas
      return (median * 100).roundToDouble() / 100.0;
    } catch (_) {
      return null;
    }
  }

  String _formatCurrency(double v) {
    // Formatação simples em R$ (sem depender de intl aqui)
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }

  // Cálculo de Páscoa (algoritmo de Meeus/Jones/Butcher)
  DateTime _easterDate(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31; // 3=Mar, 4=Abr
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  // Carnaval brasileiro: terça-feira de carnaval = 47 dias antes da Páscoa
  DateTime _carnivalDate(int year) {
    final easter = _easterDate(year);
    return easter.subtract(const Duration(days: 47));
  }
}
