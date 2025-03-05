import 'package:firebase_messaging/firebase_messaging.dart';

Future<bool> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("🔔 Người dùng đã cấp quyền thông báo");
    return true;
  } else {
    print("❌ Người dùng từ chối hoặc chưa cấp quyền");
    return false;
  }

  String? token = await messaging.getToken();
  if (token != null) {
    print('Registration Token=$token');
  }
}