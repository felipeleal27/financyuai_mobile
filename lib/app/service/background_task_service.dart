import 'package:workmanager/workmanager.dart';
import 'package:neo_financyuai/app/service/firebase_sync_service.dart';
import 'package:neo_financyuai/app/service/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neo_financyuai/firebase_options.dart';

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

  /// Inicializa as tarefas em segundo plano
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Agenda tarefas periódicas
    await _schedulePeriodicTasks();
    
    if (kDebugMode) {
      print('🔄 Background Tasks inicializadas');
    }
  }

  /// Agenda tarefas periódicas
  static Future<void> _schedulePeriodicTasks() async {
    // Sincronização a cada 15 minutos
    await Workmanager().registerPeriodicTask(
      syncTask,
      syncTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    // Lembrete diário às 20h
    await Workmanager().registerPeriodicTask(
      reminderTask,
      reminderTask,
      frequency: const Duration(hours: 24),
      initialDelay: _getDelayUntil20h(),
    );

    // Relatório diário às 22h
    await Workmanager().registerPeriodicTask(
      dailyReportTask,
      dailyReportTask,
      frequency: const Duration(hours: 24),
      initialDelay: _getDelayUntil22h(),
    );
  }

  /// Calcula delay até às 20h
  static Duration _getDelayUntil20h() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 20, 0);
    
    if (target.isBefore(now)) {
      // Se já passou das 20h hoje, agenda para amanhã
      return target.add(const Duration(days: 1)).difference(now);
    }
    
    return target.difference(now);
  }

  /// Calcula delay até às 22h
  static Duration _getDelayUntil22h() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 22, 0);
    
    if (target.isBefore(now)) {
      return target.add(const Duration(days: 1)).difference(now);
    }
    
    return target.difference(now);
  }

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
        case BackgroundTaskService.syncTask:
          await _executeSyncTask();
          break;
          
        case BackgroundTaskService.reminderTask:
          await _executeReminderTask();
          break;
          
        case BackgroundTaskService.dailyReportTask:
          await _executeDailyReportTask();
          break;
      }
      
      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('Erro na tarefa $task: $e');
      }
      return Future.value(false);
    }
  });
}

/// Executa sincronização em segundo plano
Future<void> _executeSyncTask() async {
  try {
    // Inicializa Firebase se necessário
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final syncService = FirebaseSyncService();
    await syncService.forcSync();
    
    if (kDebugMode) {
      print('🔄 Sincronização em background executada');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Erro na sincronização background: $e');
    }
  }
}

/// Executa lembrete diário
Future<void> _executeReminderTask() async {
  final notificationService = NotificationService();
  await notificationService.reminderAddTransaction();
  
  if (kDebugMode) {
    print('🔔 Lembrete diário enviado');
  }
}

/// Executa relatório diário
Future<void> _executeDailyReportTask() async {
  // Aqui você pode calcular estatísticas do dia
  // e enviar uma notificação com o resumo
  
  final notificationService = NotificationService();
  
  // Exemplo: calcula gastos do dia
  // final today = DateTime.now();
  // final dailyExpenses = await calculateDailyExpenses(today);
  
  // Usando método público da NotificationService
  await notificationService.notifyMonthlyReport();
  
  if (kDebugMode) {
    print('📊 Relatório diário gerado');
  }
}
