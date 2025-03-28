import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

class PaymentEndpoints {
  static const String basePath = '/Payment';
  static const String subscribe = '$basePath/subscribe';
  static const String executePayment = '$basePath/execute-payment';
}

class SubscriptionRequest {
  final int subscriptionPlanId;
  final String paymentFrequency;
  final bool autoRenew;

  SubscriptionRequest({
    required this.subscriptionPlanId,
    required this.paymentFrequency,
    required this.autoRenew,
  });

  Map<String, dynamic> toJson() {
    return {
      'subscriptionPlanId': subscriptionPlanId,
      'paymentFrequency': paymentFrequency,
      'autoRenew': autoRenew,
    };
  }
}

class PaymentApiService {
  final DioClient _dioClient;

  PaymentApiService(this._dioClient);

  Future<String> executePayment({
    required String paymentId,
    required String payerId,
    required String subscriptionId,
  }) async {
    try {
      final response = await _dioClient.post(
        '${PaymentEndpoints.executePayment}?paymentId=$paymentId&payerId=$payerId&subscriptionId=$subscriptionId',
      );
      
      if (response.data is Map) {
        return response.data['message'] ?? 'Payment executed successfully';
      }
      return response.data.toString();
    } catch (e) {
      print('Error executing payment: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> subscribe(SubscriptionRequest request) async {
    try {
      final response = await _dioClient.post(
        PaymentEndpoints.subscribe,
        data: request.toJson(),
      );
      
      print('Payment Subscribe Response: ${response.data}');
      
      return response.data;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}