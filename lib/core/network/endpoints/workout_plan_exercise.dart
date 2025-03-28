import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';
import 'subscription_plan.dart';

class WorkoutPlanExerciseEndpoints {
  static const String basePath = '/WorkoutPlanExercise';
  static const String getWorkoutPlanExercises = basePath;
  static const String getWorkoutPlanExerciseById = '$basePath/';
}

class WorkoutPlanExerciseApiService {
  final DioClient _dioClient;

  WorkoutPlanExerciseApiService(this._dioClient);

  Future<List<WorkoutPlanExercise>> getWorkoutPlanExercises() async {
    try {
      final response = await _dioClient.get(WorkoutPlanExerciseEndpoints.getWorkoutPlanExercises);
      return (response.data as List)
          .map((item) => WorkoutPlanExercise.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<WorkoutPlanExercise> getWorkoutPlanExerciseById(int id) async {
    try {
      final response = await _dioClient.get('${WorkoutPlanExerciseEndpoints.getWorkoutPlanExerciseById}$id');
      return WorkoutPlanExercise.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}