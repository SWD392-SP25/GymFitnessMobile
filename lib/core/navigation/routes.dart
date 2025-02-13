import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/features/home/presentation/pages/homepage.dart';
import 'package:gym_fitness_mobile/features/welcome/presentation/pages/welcome.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => Welcome());
      case home:
        return MaterialPageRoute(builder: (_) => const Homepage());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Page not found')),
            ));
    }
  }
}
