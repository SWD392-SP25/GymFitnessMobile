import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

// Định nghĩa các endpoint
class SubscriptionPlanEndpoints {
  static const String basePath = '/SubscriptionPlan';
  static const String getPlans = basePath;
  static const String getPlanById =
      '$basePath/'; // Will be concatenated with ID
}

// Model cho Subscription Plan
class Exercise {
  final int exerciseId;
  final String name;
  final String description;
  final int muscleGroupId;
  final int categoryId;
  final int difficultyLevel;
  final String equipmentNeeded;
  final String videoUrl;
  final String? imageUrl; // 👉 Thêm thuộc tính imageUrl

  Exercise(
      {required this.exerciseId,
      required this.name,
      required this.description,
      required this.muscleGroupId,
      required this.categoryId,
      required this.difficultyLevel,
      required this.equipmentNeeded,
      required this.videoUrl,
      this.imageUrl});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'],
      name: json['name'],
      description: json['description'],
      muscleGroupId: json['muscleGroupId'],
      categoryId: json['categoryId'],
      difficultyLevel: json['difficultyLevel'],
      equipmentNeeded: json['equipmentNeeded'],
      videoUrl: json['videoUrl'] ?? '',
    );
  }
}

class WorkoutPlanExercise {
  final int planId;
  final int exerciseId;
  final int weekNumber;
  final int dayOfWeek;
  final int sets;
  final int reps;
  final int restTimeSeconds;
  final String notes;
  final Exercise exercise;

  WorkoutPlanExercise({
    required this.planId,
    required this.exerciseId,
    required this.weekNumber,
    required this.dayOfWeek,
    required this.sets,
    required this.reps,
    required this.restTimeSeconds,
    required this.notes,
    required this.exercise,
  });

  factory WorkoutPlanExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanExercise(
      planId: json['planId'],
      exerciseId: json['exerciseId'],
      weekNumber: json['weekNumber'],
      dayOfWeek: json['dayOfWeek'],
      sets: json['sets'],
      reps: json['reps'],
      restTimeSeconds: json['restTimeSeconds'],
      notes: json['notes'] ?? '',
      exercise: json['exercise'] != null
          ? Exercise.fromJson(json['exercise'])
          : Exercise(
              exerciseId: json['exerciseId'],
              name: 'Exercise ${json['exerciseId']}',
              description: '',
              muscleGroupId: 0,
              categoryId: 0,
              difficultyLevel: 0,
              equipmentNeeded: '',
              videoUrl: '',
            ),
    );
  }
}

class WorkoutPlan {
  final int planId;
  final String name;
  final String description;
  final int difficultyLevel;
  final int durationWeeks;
  final String createdBy;
  final String targetAudience;
  final String goals;
  final String prerequisites;
  final DateTime createdAt;
  final int subscriptionPlanId;
  final List<WorkoutPlanExercise> workoutPlanExercises;

  WorkoutPlan({
    required this.planId,
    required this.name,
    required this.description,
    required this.difficultyLevel,
    required this.durationWeeks,
    required this.createdBy,
    required this.targetAudience,
    required this.goals,
    required this.prerequisites,
    required this.createdAt,
    required this.subscriptionPlanId,
    required this.workoutPlanExercises,
  });

  /// 👉 Thêm phương thức copyWith()
  WorkoutPlan copyWith({
    int? planId,
    String? name,
    String? description,
    int? difficultyLevel,
    int? durationWeeks,
    String? createdBy,
    String? targetAudience,
    String? goals,
    String? prerequisites,
    DateTime? createdAt,
    int? subscriptionPlanId,
    List<WorkoutPlanExercise>? workoutPlanExercises,
  }) {
    return WorkoutPlan(
      planId: planId ?? this.planId,
      name: name ?? this.name,
      description: description ?? this.description,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      createdBy: createdBy ?? this.createdBy,
      targetAudience: targetAudience ?? this.targetAudience,
      goals: goals ?? this.goals,
      prerequisites: prerequisites ?? this.prerequisites,
      createdAt: createdAt ?? this.createdAt,
      subscriptionPlanId: subscriptionPlanId ?? this.subscriptionPlanId,
      workoutPlanExercises: workoutPlanExercises ?? this.workoutPlanExercises,
    );
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      planId: json['planId'],
      name: json['name'],
      description: json['description'],
      difficultyLevel: json['difficultyLevel'],
      durationWeeks: json['durationWeeks'],
      createdBy: json['createdBy'],
      targetAudience: json['targetAudience'],
      goals: json['goals'],
      prerequisites: json['prerequisites'],
      createdAt: DateTime.parse(json['createdAt']),
      subscriptionPlanId: json['subscriptionPlanId'],
      workoutPlanExercises: (json['workoutPlanExercises'] as List?)
              ?.map((e) => WorkoutPlanExercise.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SubscriptionPlan {
  final int subscriptionPlanId;
  final String name;
  final String description;
  final double price;
  final int durationMonths;
  final bool isActive;
  final DateTime createdAt;
  final List<WorkoutPlan> workoutPlans;
  int subscriptionId;

  SubscriptionPlan({
    required this.subscriptionPlanId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMonths,
    required this.isActive,
    required this.createdAt,
    required this.workoutPlans,
    this.subscriptionId = 0,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      subscriptionPlanId: json['subscriptionPlanId'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      durationMonths: json['durationMonths'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      workoutPlans: (json['workoutPlans'] as List?)
              ?.map((e) => WorkoutPlan.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// Service để gọi API Subscription Plan
class SubscriptionPlanApiService {
  final DioClient _dioClient;

  SubscriptionPlanApiService(this._dioClient);

  // Lấy danh sách gói tập
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await _dioClient.get(SubscriptionPlanEndpoints.getPlans);
      return (response.data as List)
          .map((item) => SubscriptionPlan.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  // New method to get subscription plan by ID
  Future<SubscriptionPlan> getSubscriptionPlanById(int id) async {
    try {
<<<<<<< Updated upstream
      final response =
          await _dioClient.get('${SubscriptionPlanEndpoints.getPlanById}$id');

      print('Subscription Plan Detail API Response: ${response.data}');

=======
      final response = await _dioClient.get('${SubscriptionPlanEndpoints.getPlanById}$id');      
>>>>>>> Stashed changes
      return SubscriptionPlan.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
