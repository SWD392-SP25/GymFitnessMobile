import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

// Định nghĩa các endpoint
class SubscriptionPlanEndpoints {
  static const String basePath = '/SubscriptionPlan';
  static const String getPlans = basePath;
}

// Model cho Subscription Plan
class SubscriptionPlan {
  final int planId;
  final String name;
  final String description;
  final double price;
  final int durationMonths;
  final bool isActive;

  SubscriptionPlan({
    required this.planId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMonths,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      planId: json['planId'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      durationMonths: json['durationMonths'],
      isActive: json['isActive'],
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

      // Log dữ liệu nhận được
      print('Subscription Plan API Response: ${response.data}');

      return (response.data as List)
          .map((item) => SubscriptionPlan.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
