import 'package:dio/dio.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/dio_exceptions.dart';

class StaffEndpoints {
  static const String basePath = '/Staff';
  static const String getStaffById = '$basePath/{id}';
  static const String getAllStaff = basePath; // Add this line
}

class Staff {
  final String staffId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;  // Changed from roleId to role as String
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
  final List<dynamic> staffSpecializations;
  final dynamic supervisor;
  final List<dynamic> workoutPlans;

  Staff({
    required this.staffId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,  // Updated parameter
    this.phone,
    this.hireDate,
    this.terminationDate,
    this.salary,
    required this.status,
    this.department,
    this.supervisorId,
    required this.createdAt,
    this.lastLogin,
    this.appointments = const [],  // Made optional with default value
    this.chatHistories = const [], // Made optional with default value
    this.inverseSupervisor = const [], // Made optional with default value
    this.registeredDevices = const [], // Made optional with default value
    this.staffSpecializations = const [], // Made optional with default value
    this.supervisor,
    this.workoutPlans = const [], // Made optional with default value
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      staffId: json['staffId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'], // Updated from roleId
      phone: json['phone'],
      hireDate: json['hireDate'],
      terminationDate: json['terminationDate'],
      salary: json['salary'] != null ? (json['salary'] as num).toDouble() : null,
      status: json['status'],
      department: json['department'],
      supervisorId: json['supervisorId'],
      createdAt: json['createdAt'],
      lastLogin: json['lastLogin'],
      appointments: List<dynamic>.from(json['appointments'] ?? []),
      chatHistories: List<dynamic>.from(json['chatHistories'] ?? []),
      inverseSupervisor: List<dynamic>.from(json['inverseSupervisor'] ?? []),
      registeredDevices: List<dynamic>.from(json['registeredDevices'] ?? []),
      staffSpecializations: List<dynamic>.from(json['staffSpecializations'] ?? []),
      supervisor: json['supervisor'],
      workoutPlans: List<dynamic>.from(json['workoutPlans'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role, // Updated from roleId
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
      'staffSpecializations': staffSpecializations,
      'supervisor': supervisor,
      'workoutPlans': workoutPlans,
    };
  }
}

class StaffApiService {
  final DioClient _dioClient;

  StaffApiService(this._dioClient);

  // Add method to get all staff
  Future<List<Staff>> getAllStaff() async {
    try {
      final response = await _dioClient.get(StaffEndpoints.getAllStaff);
      return (response.data as List)
          .map((json) => Staff.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

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
