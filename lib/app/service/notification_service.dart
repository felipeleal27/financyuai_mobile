import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Serviço responsável pelo gerenciamento de notificações
/// 
/// Implementa padrão Singleton e integra:
/// - Firebase Cloud Messaging (FCM)
/// - Notificações locais
/// - Notificações agendadas
/// - Diferentes tipos de notificações financeiras
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  /// Retorna a instância singleton do serviço
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    // Inicializa timezone para notificações agendadas
    tz.initializeTimeZones();
    
    try {
      await _requestPermissions();
      debugPrint('✅ Permissões de notificação obtidas');
    } catch (e) {
      debugPrint('⚠️ Erro ao solicitar permissões: $e');
    }
    
    try {
      await _initializeLocalNotifications();
      debugPrint('✅ Notificações locais inicializadas');
    } catch (e) {
      debugPrint('⚠️ Erro ao inicializar notificações locais: $e');
    }
    
    try {
      await _setupFirebaseMessaging();
      debugPrint('✅ Firebase Messaging configurado');
    } catch (e) {
      debugPrint('⚠️ Erro ao configurar Firebase Messaging: $e');
    }
    
    try {
      await _setupBackgroundHandler();
      debugPrint('✅ Background handler configurado');
    } catch (e) {
      debugPrint('⚠️ Erro ao configurar background handler: $e');
    }
    
    debugPrint('🔔 Notification Service inicializado (com possíveis limitações)');
  }

  /// Solicita permissões para notificações
  Future<void> _requestPermissions() async {
    // Permissões Firebase
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('Permissão de notificação: ${settings.authorizationStatus}');
    }

    // Permissões locais para Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Inicializa notificações locais
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Configura Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    try {
      // Token para identificar o dispositivo
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM Token: $token');
      }

      // Salva o token localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token ?? '');

      // Listener para quando o token muda
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        await prefs.setString('fcm_token', token);
        if (kDebugMode) {
          debugPrint('Novo FCM Token: $token');
        }
      });
    } catch (e) {
      // Se Firebase Messaging não estiver disponível, continua sem ele
      debugPrint('⚠️ Firebase Messaging não disponível: $e');
      debugPrint('📱 App continuará funcionando sem notificações push');
      
      // Salva token vazio para indicar que FCM não está disponível
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', '');
    }

    // Listener para mensagens em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listener para quando o app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Handler para mensagens em segundo plano
  Future<void> _setupBackgroundHandler() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Manipula notificação quando app está em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('Mensagem recebida em foreground: ${message.notification?.title}');
    }

    _showLocalNotification(
      title: message.notification?.title ?? 'Nova notificação',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  /// Manipula quando app é aberto via notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('App aberto via notificação: ${message.data}');
    }
    
    // Navegar para tela específica baseado no tipo
    _navigateBasedOnNotification(message.data);
  }

  /// Quando notificação local é tocada
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('Notificação local tocada: ${response.payload}');
    }
  }

  /// Mostra notificação local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'financyuai_channel',
      'FinancYuAI Notificações',
      channelDescription: 'Notificações do app FinancYuAI',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2196F3),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: data?.toString(),
    );
  }

  /// Navega baseado no tipo de notificação
  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'nova_movimentacao':
        // Navegar para tela de transações
        break;
      case 'lembrete_meta':
        // Navegar para tela de metas
        break;
      case 'relatorio_mensal':
        // Navegar para relatórios
        break;
      default:
        // Navegar para home
        break;
    }
  }

  /// Notificação de meta atingida
  Future<void> notifyGoalReached(String goalName, double amount) async {
    await _showLocalNotification(
      id: 1,
      title: '🎯 Meta Atingida!',
      body: 'Parabéns! Você atingiu a meta "$goalName" de R\$ ${amount.toStringAsFixed(2)}',
      data: {'type': 'goal_reached', 'goalName': goalName},
    );
  }

  /// Lembrete para adicionar transação
  Future<void> reminderAddTransaction() async {
    await _showLocalNotification(
      id: 3,
      title: '💰 Lembrete',
      body: 'Não se esqueça de registrar suas transações de hoje!',
      data: {'type': 'reminder_transaction'},
    );
  }

  /// Relatório mensal disponível
  Future<void> notifyMonthlyReport() async {
    await _showLocalNotification(
      id: 4,
      title: '📊 Relatório Mensal',
      body: 'Seu relatório financeiro mensal está pronto! Toque para visualizar.',
      data: {'type': 'monthly_report'},
    );
  }

  /// Notificação de gasto alto
  Future<void> notifyHighExpense(double amount) async {
    await _showLocalNotification(
      id: 2,
      title: '⚠️ Gasto Alto Detectado',
      body: 'Você gastou R\$ ${amount.toStringAsFixed(2)} hoje. Fique atento ao seu orçamento!',
      data: {'type': 'high_expense', 'amount': amount.toString()},
    );
  }

  /// Notificação quando ultrapassar orçamento mensal
  Future<void> notifyBudgetExceeded({
    required double budgetLimit,
    required double currentExpenses,
    required String category,
  }) async {
    final percentage = (currentExpenses / budgetLimit * 100).round();
    
    await _showLocalNotification(
      id: 5,
      title: '🚨 Orçamento Ultrapassado!',
      body: 'Você gastou R\$ ${currentExpenses.toStringAsFixed(2)} em $category ($percentage% do orçamento)',
      data: {
        'type': 'budget_exceeded',
        'category': category,
        'amount': currentExpenses.toString(),
        'percentage': percentage.toString(),
      },
    );
  }

  /// Notificação de economia conquistada
  Future<void> notifySavingsAchieved(double savedAmount) async {
    await _showLocalNotification(
      id: 6,
      title: '🎉 Economia Conquistada!',
      body: 'Parabéns! Você economizou R\$ ${savedAmount.toStringAsFixed(2)} este mês!',
      data: {'type': 'savings_achieved', 'amount': savedAmount.toString()},
    );
  }

  /// Configura lembretes automáticos financeiros
  Future<void> setupFinancialReminders() async {
    // Lembrete diário às 20h para registrar transações
    await scheduleDailyReminder(
      hour: 20,
      minute: 0,
      title: '💰 Hora de registrar!',
      body: 'Não se esqueça de adicionar suas transações de hoje',
      data: {'type': 'daily_reminder', 'action': 'add_transaction'},
    );

    // Lembrete às 22h para revisar gastos
    await scheduleDailyReminder(
      hour: 22,
      minute: 0,
      title: '📊 Revisão Diária',
      body: 'Como foram seus gastos hoje? Confira seu resumo!',
      data: {'type': 'daily_review', 'action': 'view_summary'},
    );

    if (kDebugMode) {
      debugPrint('✅ Lembretes financeiros configurados');
    }
  }

  /// Agenda lembrete diário (ex: todo dia às 20h)
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // Se o horário já passou hoje, agenda para amanhã
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
    
    await _localNotifications.zonedSchedule(
      hour * 100 + minute, // ID único baseado no horário
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Lembretes Diários',
          channelDescription: 'Lembretes automáticos diários',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repete diariamente
      payload: data?.toString(),
    );
    
    if (kDebugMode) {
      debugPrint('📅 Lembrete diário agendado para ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }
  }

  /// Obtém o token FCM atual
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Cancela notificação agendada
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

/// Handler para mensagens em background (deve estar fora da classe)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('Mensagem em background: ${message.notification?.title}');
  }
}
