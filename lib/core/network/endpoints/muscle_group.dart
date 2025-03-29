import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

// Định nghĩa các endpoint
class MuscleGroupEndpoints {
  static const String basePath = '/MuscleGroup';
  static const String getMuscleGroup = basePath;
  static const String getMuscleGroupById = '$basePath/{id}';
}

class Exercise {
  final int exerciseId;
  final String name;
  final String description;
  final String muscleGroupName;
  final String categoryName;
  final int difficultyLevel;
  final String equipmentNeeded;
  final String videoUrl;
  final String imageUrl;
  final String instructions;
  final String precautions;
  final DateTime createdAt;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.description,
    required this.muscleGroupName,
    required this.categoryName,
    required this.difficultyLevel,
    required this.equipmentNeeded,
    required this.videoUrl,
    required this.imageUrl,
    required this.instructions,
    required this.precautions,
    required this.createdAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'],
      name: json['name'],
      description: json['description'],
      muscleGroupName: json['muscleGroupName'],
      categoryName: json['categoryName'],
      difficultyLevel: json['difficultyLevel'],
      equipmentNeeded: json['equipmentNeeded'],
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
      instructions: json['instructions'],
      precautions: json['precautions'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MuscleGroup {
  final int muscleGroupId;
  final String name;
  final String description;
  final String imageUrl;
  final List<Exercise> exercises;

  MuscleGroup({
    required this.muscleGroupId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.exercises,
  });

  factory MuscleGroup.fromJson(Map<String, dynamic> json) {
    return MuscleGroup(
      muscleGroupId: json['muscleGroupId'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      exercises: (json['exercises'] as List?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
    );
  }
}

class MuscleGroupApiService {
  final DioClient _dioClient;

  MuscleGroupApiService(this._dioClient);

  Future<List<MuscleGroup>> getMuscleGroups() async {
    try {
      final response = await _dioClient.get(MuscleGroupEndpoints.getMuscleGroup);
      return (response.data as List)
          .map((item) => MuscleGroup.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<MuscleGroup> getMuscleGroupById(int id) async {
    try {
      final response = await _dioClient.get(
        MuscleGroupEndpoints.getMuscleGroupById.replaceAll('{id}', id.toString()),
      );
      return MuscleGroup.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
