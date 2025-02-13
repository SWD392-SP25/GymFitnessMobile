import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Text(
          'Course Page', // Text in the center
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
