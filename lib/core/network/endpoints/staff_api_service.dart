import 'package:dio/dio.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/dio_exceptions.dart';

class StaffEndpoints {
  static const String basePath = '/Staff';
  static const String getStaffById = '$basePath/{id}';
}

class Staff {
  final String staffId;
  final String email;
  final String? firstName;
  final String? lastName;
  final int roleId;
  final String? phone;
  final String? hireDate;
  final String? terminationDate;
  final double? salary;
  final String status;
  final String? department;
  final String? supervisorId;
  final String createdAt;
  final String? lastLogin;
  final List<dynamic> appointments;
  final List<dynamic> chatHistories;
  final List<dynamic> inverseSupervisor;
  final List<dynamic> registeredDevices;
  final dynamic role;
  final List<dynamic> staffSpecializations;
  final dynamic supervisor;
  final List<dynamic> workoutPlans;

  Staff({
    required this.staffId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.roleId,
    this.phone,
    this.hireDate,
    this.terminationDate,
    this.salary,
    required this.status,
    this.department,
    this.supervisorId,
    required this.createdAt,
    this.lastLogin,
    required this.appointments,
    required this.chatHistories,
    required this.inverseSupervisor,
    required this.registeredDevices,
    this.role,
    required this.staffSpecializations,
    this.supervisor,
    required this.workoutPlans,
  });

  // Chuyển từ JSON sang đối tượng Staff
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      staffId: json['staffId'],
      email: json['email'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      roleId: json['roleId'],
      phone: json['phone'],
      hireDate: json['hireDate'],
      terminationDate: json['terminationDate'],
      salary:
          json['salary'] != null ? (json['salary'] as num).toDouble() : null,
      status: json['status'],
      department: json['department'],
      supervisorId: json['supervisorId'],
      createdAt: json['createdAt'],
      lastLogin: json['lastLogin'],
      appointments: List<dynamic>.from(json['appointments'] ?? []),
      chatHistories: List<dynamic>.from(json['chatHistories'] ?? []),
      inverseSupervisor: List<dynamic>.from(json['inverseSupervisor'] ?? []),
      registeredDevices: List<dynamic>.from(json['registeredDevices'] ?? []),
      role: json['role'],
      staffSpecializations:
          List<dynamic>.from(json['staffSpecializations'] ?? []),
      supervisor: json['supervisor'],
      workoutPlans: List<dynamic>.from(json['workoutPlans'] ?? []),
    );
  }

  // Chuyển từ đối tượng Staff sang JSON
  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roleId': roleId,
      'phone': phone,
      'hireDate': hireDate,
      'terminationDate': terminationDate,
      'salary': salary,
      'status': status,
      'department': department,
      'supervisorId': supervisorId,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'appointments': appointments,
      'chatHistories': chatHistories,
      'inverseSupervisor': inverseSupervisor,
      'registeredDevices': registeredDevices,
      'role': role,
      'staffSpecializations': staffSpecializations,
      'supervisor': supervisor,
      'workoutPlans': workoutPlans,
    };
  }
}

class StaffApiService {
  final DioClient _dioClient;

  StaffApiService(this._dioClient);

  Future<Staff> getStaffById(String staffId) async {
    try {
      final response = await _dioClient.get(
          StaffEndpoints.getStaffById.replaceAll('{id}', staffId.toString()));
      return Staff.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
