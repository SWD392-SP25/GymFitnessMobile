import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentDetailPage extends StatefulWidget {
  final int appointmentId;
  const AppointmentDetailPage({super.key, required this.appointmentId});

  @override
  _AppointmentDetailPageState createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = false;
  String? _errorMessage;
  AppointmentDetail? _appointment;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dioClient.dio.get(
        AppointmentEndpoints.getById(widget.appointmentId),
      );

      setState(() {
        _appointment = AppointmentDetail.fromJson(response.data);
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Detail')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Error: $_errorMessage"))
              : _appointment == null
                  ? const Center(
                      child: Text("No appointment details available"))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          Text(
                            'Trainer: ${_appointment!.staff?.email ?? 'Unknown'}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Type: ${_appointment!.type?.name ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description: ${_appointment!.type?.description ?? 'No description available'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Duration: ${_appointment!.type?.durationMinutes ?? 'Unknown'} minutes',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: \$${_appointment!.type?.price ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start Time: ${_formatDateTime(_appointment!.startTime)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'End Time: ${_formatDateTime(_appointment!.endTime)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location: ${_appointment!.location ?? 'Not specified'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${_appointment!.status ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Notes: ${_appointment!.notes ?? 'No notes available'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Trainer Details:',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email: ${_appointment!.staff?.email ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'FirstName: ${_appointment!.staff?.firstName ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'LastName: ${_appointment!.staff?.lastName ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Phone: ${_appointment!.staff?.phone ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
    );
  }
}
