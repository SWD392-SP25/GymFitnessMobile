import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../dio_exceptions.dart';

// Định nghĩa các endpoint
class MuscleGroupEndpoints {
  static const String basePath = '/MuscleGroup';
  static const String getMuscleGroup = basePath;
}

// Model cho Muscle Group
class MuscleGroup {
  final String name;
  final String description;
  final String imageUrl;

  MuscleGroup({
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory MuscleGroup.fromJson(Map<String, dynamic> json) {
    return MuscleGroup(
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

// Service để gọi API Muscle Group
class MuscleGroupApiService {
  final DioClient _dioClient;

  MuscleGroupApiService(this._dioClient);

  // Lấy danh sách nhóm cơ
  Future<List<MuscleGroup>> getMuscleGroup() async {
    try {
      final response = await _dioClient.get(MuscleGroupEndpoints.getMuscleGroup);

      // Log dữ liệu nhận được
      print('Muscle Group API Response: ${response.data}');
      
      return (response.data as List)
          .map((item) => MuscleGroup.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
