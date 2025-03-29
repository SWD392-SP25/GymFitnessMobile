import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';
import 'subscription_plan.dart';

class WorkoutPlanEndpoints {
  static const String basePath = '/WorkoutPlan';
  static const String getWorkoutPlans = basePath;
  static const String getWorkoutPlanById = '$basePath/';
}

class WorkoutPlanApiService {
  final DioClient _dioClient;

  WorkoutPlanApiService(this._dioClient);

 Future<List<WorkoutPlan>> getWorkoutPlans() async {
  try {
    final response = await _dioClient.get(WorkoutPlanEndpoints.getWorkoutPlans);

    if (response.data == null || response.data is! List) {
      throw Exception("Workout Plans API returned invalid data: ${response.data}");
    }

    return (response.data as List)
        .map((item) => WorkoutPlan.fromJson(item as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final errorMessage = DioExceptions.fromDioError(e).toString();
    throw errorMessage;
  }
}


  Future<WorkoutPlan> getWorkoutPlanById(int id) async {
  try {
    final response = await _dioClient.get('${WorkoutPlanEndpoints.getWorkoutPlanById}$id');
        
    if (response.data == null) {
      throw Exception("Error: API returned null data for WorkoutPlan ID: $id");
    }

    return WorkoutPlan.fromJson(response.data);
  } on DioException catch (e) {
    final errorMessage = DioExceptions.fromDioError(e).toString();
    throw errorMessage;
  }
}

}