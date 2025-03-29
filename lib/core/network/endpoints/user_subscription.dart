import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

class UserSubscriptionEndpoints {
  static const String basePath = '/UserSubscription';
  static String getUserSubscriptions(String email) => 
      '$basePath?filterOn=email&filterQuery=$email&pageNumber=1&pageSize=1000';
}

class UserSubscription {
  final int subscriptionId;
  final String userEmail;
  final int subscriptionPlanId;
  final String subscriptionPlanName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String paymentFrequency;
  final bool autoRenew;
  final DateTime createdAt;

  UserSubscription({
    required this.subscriptionId,
    required this.userEmail,
    required this.subscriptionPlanId,
    required this.subscriptionPlanName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentFrequency,
    required this.autoRenew,
    required this.createdAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      subscriptionId: json['subscriptionId'] ?? 0,
      userEmail: json['userEmail'] ?? '',
      subscriptionPlanId: json['subscriptionPlanId'] ?? 0,
      subscriptionPlanName: json['subscriptionPlanName'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? '',
      paymentFrequency: json['paymentFrequency'] ?? '',
      autoRenew: json['autoRenew'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class UserSubscriptionApiService {
  final DioClient _dioClient;

  UserSubscriptionApiService(this._dioClient);

  Future<List<UserSubscription>> getUserSubscriptions(String email) async {
    try {
      final response = await _dioClient.get(
        UserSubscriptionEndpoints.getUserSubscriptions(email)
      );
      print(response.data);
      // Convert response to list of UserSubscription and filter active ones
      final subscriptions = (response.data as List)
          .map((item) => UserSubscription.fromJson(item))
          .where((subscription) => subscription.status == 'Active')
          .toList();
      
      return subscriptions;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}