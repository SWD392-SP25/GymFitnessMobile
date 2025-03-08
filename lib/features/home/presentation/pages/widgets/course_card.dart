import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String buttonText;
  final String backgroundImage;

  const CourseCard({super.key, required this.title, required this.buttonText, required this.backgroundImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
