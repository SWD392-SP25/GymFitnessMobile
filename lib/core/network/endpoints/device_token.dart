import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

class DeviceTokenEndpoints {
  static const String basePath = '/DeviceToken';
  static const String register = basePath;
}

class DeviceTokenApiService {
  final DioClient _dioClient;

  DeviceTokenApiService(this._dioClient);

  Future<void> registerDeviceToken(String fcmToken) async {
    try {
      print("📱 Registering device token...");
      await _dioClient.post(
        DeviceTokenEndpoints.register,
        data: '"$fcmToken"', // Wrap token in quotes as per Swagger example
      );
      print("✅ Device token registered successfully");
    } on DioException catch (e) {
      print("❌ Failed to register device token");
      print("🔴 Error details: ${e.response?.data}");
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}