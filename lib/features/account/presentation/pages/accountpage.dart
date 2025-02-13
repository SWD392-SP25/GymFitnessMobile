import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Text(
          'Account', // Text in the center
          style: TextStyle(
            fontSize: 24, // Set font size
            fontWeight: FontWeight.bold, // Make the text bold
            color: Colors.black, // Set text color to black
          ),
        ),
      ),
    );
  }
}
