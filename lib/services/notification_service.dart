
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Request permission for iOS and web
    await _firebaseMessaging.requestPermission();

    // Get the FCM token
    final fcmToken = await _firebaseMessaging.getToken();
    log('FCM Token: $fcmToken', name: 'NotificationService');

    // Handle messages when the app is in the background or terminated
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!', name: 'NotificationService');
      log('Message data: ${message.data}', name: 'NotificationService');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}', name: 'NotificationService');
        // Here you could show a local notification using a package like flutter_local_notifications
      }
    });
  }
}

// This needs to be a top-level function (not a class method)
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}", name: 'NotificationService');
}
