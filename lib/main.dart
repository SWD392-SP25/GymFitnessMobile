import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:flutter/foundation.dart';
import 'core/firebase/notification/notification_data_source.dart';
import 'core/firebase/notification/notification_service.dart';
import 'core/firebase/notification/request_notification_permission.dart';
import 'core/network/endpoints/device_token.dart';
import 'core/network/dio_client.dart';
import 'firebase_options.dart';
// FlutterFire's Firebase Cloud Messaging plugin
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load .env file
    await dotenv.load(fileName: ".env");
    print("🌐 .env loaded successfully");
    
    // Verify the API_URL value
    final apiUrl = dotenv.env['API_URL'];
    print("🌐 API_URL from .env: '$apiUrl'");
    
    if (apiUrl == null || apiUrl.isEmpty) {
      print("❌ API_URL is missing or empty in .env file");
    }
  } catch (e) {
    print("❌ Error loading .env file: $e");
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // 🔥 Đảm bảo Firebase đã khởi tạo trước khi dùng plugin khác.

  bool isGranted = await requestNotificationPermission();
  if (isGranted) {
    await NotificationService.initialize(); // 🔥 Thêm await để đảm bảo hàm khởi tạo hoàn thành
    NotificationDataSource notificationDataSource = NotificationDataSource();
    String? token = await notificationDataSource.getFCMToken();

    if (token != null) {
      print("🔥 FCM Token: $token");
      
      // Send token to server using DeviceTokenApiService
      try {
        final deviceTokenService = DeviceTokenApiService(DioClient());
        await deviceTokenService.registerDeviceToken(token);
      } catch (e) {
        print("❌ Failed to register device token with server: $e");
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Tin nhắn foreground nhận được!");
      print("🔹 Title: ${message.notification?.title}");
      print("🔹 Body: ${message.notification?.body}");
      print("🔹 Data: ${message.data}");

      // Hiển thị thông báo bằng local notifications
      NotificationService.showNotification(message);
    });

  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Fitness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.welcome, // Start from the Welcome screen
      onGenerateRoute: AppRoutes.generateRoute, // Use AppRoutes for routing
    );
  }
}


