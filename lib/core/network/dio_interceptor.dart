import 'package:dio/dio.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Thêm token vào header (nếu có)
    options.headers["Authorization"] = "Bearer your_access_token";

    // Log request (DEBUG mode)
    print("🔵 [REQUEST] ${options.method} ${options.path}");
    print("🔹 Headers: ${options.headers}");
    print("🔸 Data: ${options.data}");

    super.onRequest(options, handler);
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response (DEBUG mode)
    print("🟢 [RESPONSE] ${response.statusCode} ${response.data}");

    super.onResponse(response, handler);
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log lỗi (DEBUG mode)
    print("🔴 [ERROR] ${err.response?.statusCode} ${err.message}");

    // Kiểm tra lỗi 401 (Unauthorized) => Có thể refresh token tại đây
    if (err.response?.statusCode == 401) {
      // TODO: Thêm logic refresh token nếu cần
      print("🔁 Token expired! Refreshing...");
    }

    super.onError(err, handler);
    return handler.next(err);
  }
}
