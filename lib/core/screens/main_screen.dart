import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/features/appointment/presentation/pages/appointment.dart';
import 'package:gym_fitness_mobile/features/home/presentation/pages/homepage.dart';
import 'package:gym_fitness_mobile/features/course/presentation/pages/coursepage.dart';
import 'package:gym_fitness_mobile/features/chat/presentation/pages/chatpage.dart';
import 'package:gym_fitness_mobile/features/account/presentation/pages/accountpage.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CoursePage(),
    ChatbotPage(),
    AppointmentPage(),
    ChatPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Add this method to handle back button presses
  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      // If not on the home tab, go to home tab
      setState(() {
        _currentIndex = 0;
      });
      return false; // Don't exit the app
    }
    return true; // Allow exiting the app
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Course',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'GYMBOT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Appointment',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Meet PT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}