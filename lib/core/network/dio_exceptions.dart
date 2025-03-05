import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  late String message;

  DioExceptions.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout";
        break;
      case DioExceptionType.badResponse:
        message = "Bad response: ${error.response?.statusCode}";
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout";
        break;
      case DioExceptionType.badCertificate:
        message = "Bad certificate";
        break;
      case DioExceptionType.cancel:
        message = "Cancelled";
        break;
      case DioExceptionType.connectionError:
        message = "Connection error";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  @override
  String toString() => message;
}
