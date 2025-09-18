import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _fln = FlutterLocalNotificationsPlugin();

Future<void> setupPushNotifications(String uid) async {
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.subscribeToTopic('user_$uid');

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await _fln.initialize(const InitializationSettings(android: androidInit));

  FirebaseMessaging.onMessage.listen((msg) {
    final n = msg.notification;
    // Suprime notificações relacionadas à sincronização
    final type = (msg.data['type'] ?? msg.data['notification_type'] ?? '').toString().toLowerCase();
    final title = (n?.title ?? msg.data['title'] ?? '').toString().toLowerCase();
    final body = (n?.body ?? msg.data['body'] ?? '').toString().toLowerCase();
    bool isSync = type.contains('sync') ||
        type.contains('sincroniza') ||
        title.contains('sincroniz') ||
        body.contains('sincroniz') ||
        title.contains('sync') ||
        body.contains('sync');

    if (n != null && !isSync) {
      _fln.show(
        n.hashCode,
        n.title,
        n.body,
        const NotificationDetails(
          android: AndroidNotificationDetails('financyuai', 'FinancyUAI'),
        ),
      );
    }
  });
}
