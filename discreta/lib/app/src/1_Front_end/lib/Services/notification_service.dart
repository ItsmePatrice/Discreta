import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final _instance = NotificationService._privateConstructor();
  static NotificationService get instance => _instance;

  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, sound: true, badge: true);

    // Required for iOS background notifications
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    final token = await _messaging.getToken();
    await _saveToken(token);
    _messaging.onTokenRefresh.listen(_saveToken);

    // Handle silent push when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Silent push received while app is open — Flic is already connected, no action needed
    });
  }

  Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final uid = AuthService.instance.discretaUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
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
      final currentStreak = userDoc.data()?['streakCount'] as int? ?? 0;
      await _firestore.collection('users').doc(uid).update({
        'lastAppOpen': FieldValue.serverTimestamp(),
        'lastOpenDate': todayStr,
        'streakCount': currentStreak + 1,
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
    });
  }
}
