import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

// Định nghĩa các endpoint và các payload
class AuthEndpoints {
  // Base path
  static const String basePath = '/auth';

  // Endpoints
  static const String login = '$basePath/login';
  static const String refreshToken = '$basePath/refresh-token';
  static const String logout = '$basePath/logout';
}

// Model để parse response từ auth/login
class AuthResponse {
  final String token;
  final String refreshToken;
  final String id;
  final String email;
  final String role;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.id,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      id: json['id'],
      email: json['email'],
      role: json['role'],
    );
  }
}

// Model cho response từ refresh-token API
class RefreshTokenResponse {
  final String token;
  final String refreshToken;

  RefreshTokenResponse({
    required this.token,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}

// Service để gọi các API xác thực
class AuthApiService {
  final DioClient _dioClient;

  AuthApiService(this._dioClient);

  // Login với firebase idToken
  // Login với firebase idToken
Future<AuthResponse> login(String firebaseToken) async {
  try {
    // Log base URL and endpoint details
    final baseUrl = _dioClient.dio.options.baseUrl;
    final endpoint = AuthEndpoints.login;
    final fullUrl = "$baseUrl$endpoint";
    
    print("🌐 Base URL: '$baseUrl'");
    print("🌐 Endpoint: '$endpoint'");
    print("🌐 Full login URL: '$fullUrl'");
    
    // Log request payload
    print("🔑 Login payload: {'idToken': ${firebaseToken}...}");

    final response = await _dioClient.post(AuthEndpoints.login, data: {
      'idToken': firebaseToken,
    });

    return AuthResponse.fromJson(response.data);
  } on DioException catch (e) {
    // Log detailed error information
    print("🔴 API call failed URL: '${e.requestOptions.uri}'");
    print("🔴 baseUrl: '${e.requestOptions.baseUrl}'");
    print("🔴 path: '${e.requestOptions.path}'");
    print("🔴 Error type: ${e.type}");
    
    if (e.error != null) {
      print("🔴 Underlying error: ${e.error}");
    }
    
    final errorMessage = DioExceptions.fromDioError(e).toString();
    throw errorMessage;
  }
}
  // Refresh token - cập nhật theo API spec
  Future<RefreshTokenResponse> refresh({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    try {
      final response = await _dioClient.post(AuthEndpoints.refreshToken, data: {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userId': userId,
      });

      return RefreshTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  // Logout
  Future<void> logout(String accessToken) async {
    try {
      await _dioClient.post(AuthEndpoints.logout, data: {
        'accessToken': accessToken,
      });
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
