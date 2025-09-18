import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/service/ai_routine_service.dart';
import 'package:neo_financyuai/app/service/ai_holiday_service.dart';
import 'package:neo_financyuai/app/service/ai_balance_forecast_service.dart';

/// Dispara as análises de IA diariamente às ~09:00 quando o app está aberto.
/// Complementa o Workmanager (background) para garantir execução em foreground.
class ForegroundDailyScheduler {
  static final ForegroundDailyScheduler _instance = ForegroundDailyScheduler._internal();
  factory ForegroundDailyScheduler() => _instance;
  ForegroundDailyScheduler._internal();

  Timer? _timer;

  /// Inicia o agendador (idempotente).
  void start({int hour = 9, int minute = 0}) {
    _timer?.cancel();
    final delay = _nextTriggerDelay(hour: hour, minute: minute);
    _timer = Timer(delay, () async {
      try {
        if (kDebugMode) {
          final now = DateTime.now();
          print('🕘 ForegroundDailyScheduler: executando IA em ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
        }
        await AiRoutineService().runDailyAnalysis();
        await AiHolidayService().runDailyAnalysis();
  await AiBalanceForecastService().runDailyForecast();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ ForegroundDailyScheduler erro na execução: $e');
        }
      } finally {
        // Reagenda para o próximo dia
        start(hour: hour, minute: minute);
      }
    });

    if (kDebugMode) {
      print('⏱️ ForegroundDailyScheduler: agendado para daqui a ~$delay');
    }
  }

  /// Para o agendador.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Duration _nextTriggerDelay({required int hour, required int minute}) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }
}
