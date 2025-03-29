import 'package:flutter/material.dart';
import '../../../../core/network/endpoints/muscle_group.dart';

class MuscleGroupDetailPage extends StatelessWidget {
  final MuscleGroup muscleGroup;

  const MuscleGroupDetailPage({super.key, required this.muscleGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(muscleGroup.name),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Muscle Group Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  muscleGroup.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  muscleGroup.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Exercises',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Exercise List
          Expanded(
            child: ListView.builder(
              itemCount: muscleGroup.exercises.length,
              itemBuilder: (context, index) {
                final exercise = muscleGroup.exercises[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      exercise.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.fitness_center),
                        );
                      },
                    ),
                    title: Text(exercise.name),
                    subtitle: Text(exercise.description),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to exercise detail page
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}