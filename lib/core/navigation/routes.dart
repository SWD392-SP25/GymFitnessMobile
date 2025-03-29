import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/features/payment/presentation/success.dart';
import 'package:gym_fitness_mobile/features/appointment/presentation/pages/appointment.dart';
import 'package:gym_fitness_mobile/features/home/presentation/pages/homepage.dart';
import 'package:gym_fitness_mobile/features/course/presentation/pages/coursepage.dart';
import 'package:gym_fitness_mobile/features/chat/presentation/pages/chatpage.dart';
import 'package:gym_fitness_mobile/features/account/presentation/pages/accountpage.dart';
import '../../features/welcome/presentation/pages/welcome.dart';
import '../screens/main_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String mainScreen = '/mainScreen';
  static const String paymentSuccess = '/payment-success'; // Update the route name
  static const String home = '/home';
  static const String course = '/course';
  static const String chatbot = '/chatbot';
  static const String meetPt = '/meetpt';
  static const String account = '/account';
  static const String appointment = '/appoitment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => Welcome());
      case mainScreen:
        return MaterialPageRoute(builder: (_) => MainScreen());
      case paymentSuccess:
        return MaterialPageRoute(
          builder: (_) => const PaymentSuccessPage(),
          settings: settings, // Add settings
        );
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case course:
        return MaterialPageRoute(builder: (_) => CoursePage());
      case chatbot:
        return MaterialPageRoute(builder: (_) => ChatbotPage());
      case meetPt:
        return MaterialPageRoute(builder: (_) => ChatPage());
      case account:
        return MaterialPageRoute(builder: (_) => AccountPage());
      case appointment:
        return MaterialPageRoute(builder: (_) => AppointmentPage());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Không tìm thấy trang')),
            ));
    }
  }
}
