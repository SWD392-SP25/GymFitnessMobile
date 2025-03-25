import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/appointment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_fitness_mobile/core/auth/auth_provider.dart';
import 'package:dio/dio.dart'; // Add this import for Options
import 'package:gym_fitness_mobile/features/appointment/presentation/pages/appointment_detail_page.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class AppointmentPage extends ConsumerStatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends ConsumerState<AppointmentPage> {
  final DioClient _dioClient = DioClient();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _logApiCall();
    _fetchAppointments();
  }

  void _logApiCall() async {
    final token = ref.read(authTokenProvider)?.token;
    if (token == null) {
      print("⚠️ Token is null. Ensure the user is logged in.");
    } else {
      print("Navigated to AppointmentPage");
      print("API Endpoint: ${AppointmentEndpoints.basePath}");
      print("Token: $token");
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = ref.read(authTokenProvider)?.token;
      if (token == null) {
        throw Exception("⚠️ Token is null. Please log in.");
      }

      final response = await _dioClient.dio.get(
        AppointmentEndpoints.basePath,
        queryParameters: {
          'pageNumber': 1,
          'pageSize': 10,
        },
        options: Options(
          // Ensure Options is recognized
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('🟢 API Response: ${response.data}');

      setState(() {
        _appointments = (response.data as List)
            .map((item) => Appointment.fromJson(item))
            .toList();
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime); // Format time as hh:mm AM/PM
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm a')
        .format(dateTime); // Format date and time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              'Appointments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text("Error: $_errorMessage"))
                    : _appointments.isEmpty
                        ? const Center(child: Text("No appointments available"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _appointments[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: ExpansionTile(
                                    title: Text(
                                      appointment.staffName ?? 'No name',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Start: ${_formatDateTime(appointment.startTime)} \n'
                                      'End: ${_formatDateTime(appointment.endTime)}',
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appointment.description ??
                                                  'No description',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    //chưa viết hàm nhá
                                                  },
                                                  child:
                                                      const Text('Join Class'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AppointmentDetailPage(
                                                          appointmentId:
                                                              appointment
                                                                  .appointmentId,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child:
                                                      const Text('View Detail'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
