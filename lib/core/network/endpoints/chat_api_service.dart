import 'package:dio/dio.dart';

class ChatApiService {
  final Dio _dio;

  ChatApiService(this._dio);

  Future<List<Map<String, dynamic>>> getChatHistory(
      String userId, String staffId,
      {required String? token}) async {
    try {
      final response = await _dio.get(
        '/Chat/history/$userId/$staffId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Use token
          },
        ),
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to fetch chat history: $e');
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    required String messageType,
    required String? token,
  }) async {
    try {
      final requestBody = {
        "senderId": senderId,
        "receiverId": receiverId,
        "message": message,
        "messageType": messageType,
      };
      await _dio.post(
        '/Chat/send', // Updated endpoint path
        data: requestBody,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json-patch+json', // Added Content-Type header
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
