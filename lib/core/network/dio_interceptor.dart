import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/endpoints/auth.dart';

class DioInterceptor extends Interceptor {
  bool _isRefreshing = false;
  
  // List các endpoint không cần token
  final _publicEndpoints = [
    '/api/auth/login',  // Endpoint đăng nhập
    '/api/auth/refresh-token',
    '/api/auth/logout',
    // Thêm các endpoint khác không cần token vào đây
  ];
  
  bool _needsToken(String path) {
    return !_publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Log request chi tiết để debug
    print("🔵 [REQUEST] ${options.method} ${options.uri}");
    print("🔹 Headers: ${options.headers}");
    print("🔸 Data: ${options.data}");
    
    // Chỉ thêm token nếu endpoint cần token
    if (_needsToken(options.path)) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        options.headers["Authorization"] = "Bearer $token";
        print("🔑 Added token to request");
      } else {
        print("⚠️ Token required but not available");
      }
    } else {
      print("🔓 Public endpoint - No token needed");
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response chi tiết
    print("🟢 [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}");
    if (response.data != null) {
      try {
        print("🟢 [RESPONSE DATA] ${response.data}");
      } catch (e) {
        print("🟢 [RESPONSE DATA] Cannot print data: $e");
      }
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Log lỗi chi tiết
    print("🔴 [ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}");
    if (err.response?.data != null) {
      print("🔴 [ERROR RESPONSE] ${err.response?.data}");
    }
    print("🔴 [ERROR MESSAGE] ${err.message}");

    // Xử lý refresh token chỉ khi cần
    if (err.response?.statusCode == 401 && !_isRefreshing && _needsToken(err.requestOptions.path)) {
      _isRefreshing = true;
      
      try {
        // Lấy thông tin từ SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString('refreshToken');
        final accessToken = prefs.getString('token');
        final userId = prefs.getString('userId');
        
        if (refreshToken != null && accessToken != null && userId != null) {
          // Khởi tạo Dio và AuthApiService tạm thời để tránh vòng lặp
          final tempDio = Dio();
          tempDio.options.baseUrl = err.requestOptions.baseUrl;
          
          // Gọi API refresh token
          final response = await tempDio.post(
            AuthEndpoints.refreshToken,
            data: {
              'accessToken': accessToken,
              'refreshToken': refreshToken,
              'userId': userId
            }
          );
          
          // Lưu token mới vào SharedPreferences
          await prefs.setString('token', response.data['token']);
          await prefs.setString('refreshToken', response.data['refreshToken']);
          
          // Thử lại request ban đầu với token mới
          final options = err.requestOptions;
          options.headers["Authorization"] = "Bearer ${response.data['token']}";
          
          // Tạo request mới với token đã được cập nhật
          final retryResponse = await tempDio.fetch(options);
          _isRefreshing = false;
          
          // Trả về kết quả cho handler
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        print("🔴 Không thể refresh token: $e");
        _isRefreshing = false;
        
        // Xóa thông tin đăng nhập khi refresh token thất bại
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('refreshToken');
        await prefs.remove('userId');
        await prefs.remove('userEmail');
        await prefs.remove('userRole');
        
        // TODO: Chuyển đến màn hình đăng nhập
      }
    }

    return handler.next(err);
  }
}
