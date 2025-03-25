import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_fitness_mobile/core/network/dio_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio _dio = Dio();

  // Factory constructor to return the singleton instance
  factory DioClient() {
    return _instance;
  }

  // Private constructor
  DioClient._internal() {
    configureDio();
  }

  void configureDio() {
    try {
      // Get API URL with a fallback value
      String baseUrl = '';
      try {
        baseUrl = dotenv.get('API_URL');
        print("🌐 Loaded API_URL from .env: '$baseUrl'");
      } catch (e) {
        print("⚠️ Failed to load from .env: $e");
      }

      // Set default configs
      _dio.options.baseUrl = baseUrl;
      print("🌐 Dio baseUrl set to: '${_dio.options.baseUrl}'");

      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);
      _dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Thêm interceptor
      _dio.interceptors.add(DioInterceptor());
    } catch (e) {
      print("❌ Error configuring Dio: $e");
    }
  }

  // Method to manually update baseUrl if needed
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
    print("🔄 Updated baseUrl to: '$url'");
  }

  Dio get dio => _dio;

  // Improved utility methods with better logging
  Future<Response> post(String path, {dynamic data}) {
    final fullUrl = "${_dio.options.baseUrl}$path";
    print("🔹 POST request to: '$fullUrl'");
    return _dio.post(path, data: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    final fullUrl = "${_dio.options.baseUrl}$path";
    print("🔹 GET request to: '$fullUrl'");
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}
