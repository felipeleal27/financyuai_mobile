import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neo_financyuai/app/service/ai_routine_service.dart';
import 'package:neo_financyuai/app/service/ai_holiday_service.dart';
import 'package:neo_financyuai/app/service/ai_balance_forecast_service.dart';

/// Utilitário de debug para executar IAs sob demanda e limpar flags anti-spam.
class AiDebugService {
  static final AiDebugService _instance = AiDebugService._internal();
  factory AiDebugService() => _instance;
  AiDebugService._internal();

  Future<void> runAllNow() async {
    if (kDebugMode) print('🧪 IA Debug: executando todas as análises agora...');
    await AiRoutineService().runDailyAnalysis();
    await AiHolidayService().runDailyAnalysis();
    await AiBalanceForecastService().runDailyForecast();
  }

  /// Limpa apenas as flags usadas pelas IAs desta base (rotina, feriados, forecast)
  Future<int> resetIaFlags() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final patterns = [
      RegExp(r'^ai_last_notify_'),
      RegExp(r'^ai_holiday_'),
      RegExp(r'^ai_balance_forecast_'),
    ];
    int removed = 0;
    for (final k in keys) {
      if (patterns.any((p) => p.hasMatch(k))) {
        await prefs.remove(k);
        removed++;
      }
    }
    if (kDebugMode) print('🧹 IA Debug: $removed flags removidas');
    return removed;
  }
}
