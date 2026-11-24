import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler required by firebase_messaging for background/terminated state.
@pragma('vm:entry-point')
Future<void> onFcmBackgroundMessage(RemoteMessage message) async {}

class FcmService {
  static const _channelId = 'freshpine_orders';
  static const _channelName = 'FreshPine Orders';
  static final _fln = FlutterLocalNotificationsPlugin();

  /// Call once after Firebase.initializeApp(), before runApp().
  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(onFcmBackgroundMessage);
  }

  /// Request permission, set up local notifications, save the FCM token to
  /// Firestore at users/{buyerPhone}. Android-only; no-ops on other platforms.
  static Future<void> init(String buyerPhone) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Android 8+ notification channel (matches the channel used in the Cloud Function)
    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Updates on your pineapple order',
          importance: Importance.high,
        ));

    await _fln.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ));

    // Show a heads-up notification when the app is in the foreground
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;
      _fln.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });

    await _saveToken(buyerPhone);
    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => _storeToken(buyerPhone, token));
  }

  static Future<void> _saveToken(String phone) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _storeToken(phone, token);
  }

  static Future<void> _storeToken(String phone, String token) async {
    await FirebaseFirestore.instance
        .doc('users/$phone')
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
}
