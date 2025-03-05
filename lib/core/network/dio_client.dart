import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio();

  void configureDio() {
    // Set default configs
    dio.options.baseUrl = 'https://api.pub.dev';
    dio.options.connectTimeout = Duration(seconds: 5);
    dio.options.receiveTimeout = Duration(seconds: 3);

    // Or create `Dio` with a `BaseOptions` instance.
    final options = BaseOptions(
      baseUrl: 'https://api.pub.dev',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
    );
    final anotherDio = Dio(options);

    // Or clone the existing `Dio` instance with all fields.
    final clonedDio = dio.clone();
  }

  Dio get dio => _dio;
}
