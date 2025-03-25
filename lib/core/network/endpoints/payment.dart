import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

class PaymentEndpoints {
  static const String basePath = '/Payment';
  static const String subscribe = '$basePath/subscribe';
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

  Future<void> subscribe(SubscriptionRequest request) async {
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