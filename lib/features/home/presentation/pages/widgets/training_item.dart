import 'package:flutter/material.dart';

class TrainingItem extends StatelessWidget {
  final String title;
  final int current;
  final int total;

  const TrainingItem({super.key, required this.title, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    double progress = current / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // vòng tròn phần trăm
          SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),

          const SizedBox(width: 16),

          // tiến độ và tên
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '$current/$total',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
