import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_fitness_mobile/features/payment/presentation/success.dart';
import 'core/firebase/notification/notification_data_source.dart';
import 'core/firebase/notification/notification_service.dart';
import 'core/firebase/notification/request_notification_permission.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app links
  final appLinks = AppLinks();

  // Handle initial link
  try {
    final uri = await appLinks.getInitialLink(); // Changed to correct method name
    if (uri != null) {
      print('🔗 Initial URI: $uri');
      handleDeepLink(uri);
    }
  } catch (e) {
    print('❌ Error handling initial URI: $e');
  }

  // Listen to incoming links
  appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      print('🔗 Incoming URI: $uri');
      handleDeepLink(uri);
    }
  }, onError: (err) {
    print('❌ Error handling URI: $err');
  });

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
    await NotificationService
        .initialize(); // 🔥 Thêm await để đảm bảo hàm khởi tạo hoàn thành
    NotificationDataSource notificationDataSource = NotificationDataSource();
    String? token = await notificationDataSource.getFCMToken();

    if (token != null) {
      print("🔥 FCM Token: $token");
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

// Add this method before the MyApp class
void handleDeepLink(Uri uri) {
  if (uri.scheme == 'gymfitness' && uri.host == 'paypal-return') {
    final paymentId = uri.queryParameters['paymentId'];
    print('💳 Payment ID: $paymentId');
    
    // Use pushNamed instead of pushReplacementNamed
    navigatorKey.currentState?.pushNamed(AppRoutes.paymentSuccess);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Gym Fitness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.generateRoute,
      // Add routes map
      routes: {
        AppRoutes.paymentSuccess: (context) => const PaymentSuccessPage(),
      },
    );
  }
}
