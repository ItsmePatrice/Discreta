import 'dart:io';

import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/log_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final _instance = NotificationService._privateConstructor();
  static NotificationService get instance => _instance;

  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, sound: true, badge: true);

    // Required for iOS background notifications
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // Initialize local notifications
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'discreta_reminders',
      'Daily Reminders',
      description: 'Reminds you to open Discreta',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    final token = await _messaging.getToken();
    await _saveToken(token);
    _messaging.onTokenRefresh.listen(_saveToken);

    // App in FOREGROUND — show notification manually via local notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification == null) return; // silent push, ignore

      final notification = message.notification!;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'discreta_reminders',
            'Daily Reminders',
            channelDescription: 'Reminds you to open Discreta',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentSound: true,
          ),
        ),
      );
    });

    // App in BACKGROUND — user tapped the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Add navigation logic here later if needed
    });

    // App TERMINATED — launched via notification tap
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Add navigation logic here later if needed
    }

    LogService.instance.logInfo("FCM well initialized");
  }

  Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final uid = AuthService.instance.discretaUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
  }

  Future<void> saveTokenForCurrentUser() async {
    try {
      // iOS requires APNs token to be ready before FCM token can be retrieved
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          LogService.instance.logInfo(
            'APNs token not ready yet — skipping token save',
          );
          return;
        }
      }

      final token = await _messaging.getToken();
      await _saveToken(token);
      LogService.instance.logInfo('FCM token saved successfully');
    } catch (e) {
      LogService.instance.logInfo('Failed to save FCM token: $e');
    }
  }

  // Call this every time the app is foregrounded
  Future<void> recordAppOpen() async {
    final uid = AuthService.instance.discretaUser?.uid;
    if (uid == null) return;

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final lastOpenStr = userDoc.data()?['lastOpenDate'] as String?;

    // Increment streak only if this is the first open of a new day
    if (lastOpenStr != todayStr) {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr =
          '${yesterday.year}-${yesterday.month}-${yesterday.day}';
      final currentStreak = userDoc.data()?['streakCount'] as int? ?? 0;
      final newStreak = (lastOpenStr == yesterdayStr) ? currentStreak + 1 : 1;

      await _firestore.collection('users').doc(uid).update({
        'lastAppOpen': FieldValue.serverTimestamp(),
        'lastOpenDate': todayStr,
        'streakCount': newStreak,
      });
    }
  }

  Future<void> createUserDocumentForNotifications(
    String uid,
    String firstName,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'fcmToken': null,
      'lastAppOpen': null,
      'lastOpenDate': null,
      'streakCount': 0,
      'notificationTime': '09:00',
      'firstName': firstName,
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    final uid = AuthService.instance.discretaUser?.uid;
    if (uid != null) {
      // Remove token from Firestore before signing out
      await _firestore.collection('users').doc(uid).update({'fcmToken': null});
    }

    // Delete the token from FCM so it gets regenerated fresh on next login
    await _messaging.deleteToken();
  }
}
