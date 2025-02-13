import 'package:flutter/material.dart';
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

  // Danh sách các trang con của MainScreen
  final List<Widget> _pages = [
    HomePage(),
    CoursePage(),
    ChatbotPage(),
    ChatPage(),
    AccountPage(),
  ];

  // Hàm này thay đổi index của các tab
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Chỉ thay đổi nội dung body mà không làm mất Footer
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
            icon: Icon(Icons.group),
            label: 'Meet PT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        selectedItemColor: Colors.blue, // Change color for selected tab
        unselectedItemColor: Colors.grey, // Change color for unselected tabs
        showUnselectedLabels: true,
      ),
    );
  }
}
