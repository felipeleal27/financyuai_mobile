import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/service/ai_routine_service.dart';
import 'package:neo_financyuai/app/service/ai_holiday_service.dart';
import 'package:neo_financyuai/app/service/ai_balance_forecast_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/service/firebase_sync_service.dart';
import 'package:neo_financyuai/app/service/recurrence_topup_service.dart';

/// Serviço responsável por gerenciar tarefas em segundo plano
/// 
/// Utiliza WorkManager para executar:
/// - Sincronização automática com Firebase
/// - Lembretes diários
/// - Relatórios automáticos
class BackgroundTaskService {
  static const String syncTask = 'sync_task';
  static const String reminderTask = 'reminder_task';
  static const String dailyReportTask = 'daily_report_task';
  static const String aiRoutineTask = 'ai_routine_task';

  /// Inicializa as tarefas em segundo plano
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      // Desativa debug para evitar qualquer notificação/log visível do plugin
      isInDebugMode: false,
    );

    // Cancela quaisquer tarefas previamente agendadas (migração para modo sem notificações)
    try {
      await Workmanager().cancelAll();
      if (kDebugMode) {
        print('🧹 Workmanager: tarefas antigas canceladas');
      }
    } catch (_) {}

  // Agenda tarefas periódicas (somente IA)
  await _schedulePeriodicTasks();
    
    if (kDebugMode) {
      print('🔄 Background Tasks inicializadas');
    }
  }

  /// Agenda tarefas periódicas
  static Future<void> _schedulePeriodicTasks() async {
    // Agenda apenas a rotina de IA uma vez por dia, em uma janela da manhã.
    try {
  final initialDelay = _nextMorningDelay(hours: 9); // roda por volta das 09:00
      await Workmanager().registerPeriodicTask(
        aiRoutineTask,
        aiRoutineTask,
        frequency: const Duration(hours: 24),
        initialDelay: initialDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 15),
        tag: 'ai_routine',
      );
      if (kDebugMode) {
        print('🤖 Workmanager: tarefa diária da IA agendada (em ~$initialDelay)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Falha ao agendar tarefa da IA: $e');
      }
    }

    // Agenda sincronização silenciosa: processar fila quando online
    try {
      await Workmanager().registerPeriodicTask(
        syncTask,
        syncTask,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(minutes: 5),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 10),
        tag: 'background_sync',
      );
      if (kDebugMode) {
        print('🔁 Workmanager: sincronização periódica agendada a cada 15min');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Falha ao agendar sync periódico: $e');
      }
    }
  }

  /// Calcula o delay até a próxima manhã (hora específica do dia seguinte, se já passou hoje)
  static Duration _nextMorningDelay({int hours = 9, int minutes = 0}) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hours, minutes);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }

  /// Calcula delay até às 20h
  // Removido: cálculo de delay para 20h

  /// Calcula delay até às 22h
  // Removido: cálculo de delay para 22h

  /// Cancela todas as tarefas
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }

  /// Cancela tarefa específica
  static Future<void> cancelTask(String taskName) async {
    await Workmanager().cancelByUniqueName(taskName);
  }
}

/// Dispatcher para tarefas em segundo plano
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case BackgroundTaskService.aiRoutineTask:
          // Executa análises leves da IA (rotinas e feriados)
          await AiRoutineService().runDailyAnalysis();
          await AiHolidayService().runDailyAnalysis();
          await AiBalanceForecastService().runDailyForecast();
          return Future.value(true);
        case BackgroundTaskService.syncTask:
          // Sincroniza a fila se usuário estiver autenticado
          final uid = AuthService().userId;
          if (uid != null) {
            await FirebaseSyncService().processQueue(uid);
            // Executa top-up de recorrências fixas
            await RecurrenceTopUpService().runTopUp(uid);
          }
          return Future.value(true);
        case BackgroundTaskService.reminderTask:
        case BackgroundTaskService.dailyReportTask:
          // Tarefas antigas permanecem desativadas; não executar
          return Future.value(true);
        default:
          // Desconhecido: não faz nada
          return Future.value(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro no Workmanager task=$task: $e');
      }
      return Future.value(true);
    }
  });
}

// Removido: sincronização em segundo plano desativada

/// Executa lembrete diário
// Removido: lembrete diário desativado

/// Executa relatório diário
// Removido: relatório diário desativado
