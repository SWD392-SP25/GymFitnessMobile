import 'package:dio/dio.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/dio_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Định nghĩa endpoint API
class AppointmentEndpoints {
  static const String basePath = '/Appointment';
  static String getById(int id) => '$basePath/$id';
}

// Model cho Appointment
class Appointment {
  final int appointmentId;
  final String? userName; // Nullable
  final String? staffName; // Nullable
  final String? status; // Nullable
  final String? notes; // Nullable
  final String? location; // Nullable
  final DateTime startTime;
  final DateTime endTime;
  final String? description; // Nullable
  final DateTime createdAt;
  final Staff? staff; // Add this field
  final Type? type; // Add this field

  Appointment({
    required this.appointmentId,
    this.userName,
    this.staffName,
    this.status,
    this.notes,
    this.location,
    required this.startTime,
    required this.endTime,
    this.description,
    required this.createdAt,
    this.staff, // Initialize this field
    this.type, // Initialize this field
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'],
      userName: json['userName'], // Nullable
      staffName: json['staffName'], // Nullable
      status: json['status'], // Nullable
      notes: json['notes'], // Nullable
      location: json['location'], // Nullable
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      description: json['description'], // Nullable
      createdAt: DateTime.parse(json['createdAt']),
      staff: json['staff'] != null
          ? Staff.fromJson(json['staff'])
          : null, // Parse staff
      type: json['type'] != null
          ? Type.fromJson(json['type'])
          : null, // Parse type
    );
  }
}

// New class for detailed appointment information
class AppointmentDetail {
  final int appointmentId;
  final String? userName;
  final String? staffName;
  final String? status;
  final String? notes;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final DateTime createdAt;
  final Staff? staff;
  final Type? type;

  AppointmentDetail({
    required this.appointmentId,
    this.userName,
    this.staffName,
    this.status,
    this.notes,
    this.location,
    required this.startTime,
    required this.endTime,
    this.description,
    required this.createdAt,
    this.staff,
    this.type,
  });

  factory AppointmentDetail.fromJson(Map<String, dynamic> json) {
    return AppointmentDetail(
      appointmentId: json['appointmentId'],
      userName: json['userName'],
      staffName: json['staffName'],
      status: json['status'],
      notes: json['notes'],
      location: json['location'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
      type: json['type'] != null
          ? Type.fromJson({
              ...json['type'],
              'durationMinutes':
                  (json['type']['durationMinutes'] as num).toInt(),
              'price': (json['type']['price'] as num).toInt(),
            })
          : null,
    );
  }
}

// Model Staff
class Staff {
  final String staffId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String status;
  final DateTime createdAt;
  final String? phone; // Add this field

  Staff({
    required this.staffId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.status,
    required this.createdAt,
    this.phone, // Initialize this field
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      staffId: json['staffId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      phone: json['phone'], // Parse phone
    );
  }
}

// Model Type
class Type {
  final int typeId;
  final String name;
  final String description;
  final int durationMinutes;
  final int price;

  Type({
    required this.typeId,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.price,
  });

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      typeId: json['typeId'],
      name: json['name'],
      description: json['description'],
      durationMinutes: json['durationMinutes'],
      price: json['price'],
    );
  }
}

// Model User
class User {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String status;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.status,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Service để gọi API Appointment
class AppointmentApiService {
  final DioClient _dioClient;

  AppointmentApiService(this._dioClient);

  // Lấy danh sách cuộc hẹn từ API (có xác thực bằng token từ SharedPreferences)
  Future<List<Appointment>> getAppointments(
      {int pageNumber = 1, int pageSize = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("🔐 Token: ${prefs.getString('token')}");
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
            "⚠️ Không tìm thấy token. Người dùng chưa đăng nhập hoặc token đã hết hạn.");
      }
      final response = await _dioClient.dio.get(
        AppointmentEndpoints.basePath,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('🟢 API Response: ${response.data}');

      return (response.data as List)
          .map((item) => Appointment.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      print('🔴 API Error: $errorMessage');
      throw errorMessage;
    }
  }

  Future<Appointment> getAppointmentById(int id) async {
    try {
      final response = await _dioClient.get(AppointmentEndpoints.getById(id));
      return Appointment.fromJson(response.data);
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }
}
