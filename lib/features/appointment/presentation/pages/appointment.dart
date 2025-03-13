import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  AppointmentPage({super.key}); // Removed 'const' keyword

  final List<Map<String, dynamic>> appointments = [
    {
      "name": "thành nè",
      "description": "One-on-one personal training session",
      "durationMinutes": 60,
      "price": 50
    },
    {
      "name": "vavs",
      "description": "Training session with up to 5 people",
      "durationMinutes": 90,
      "price": 30
    },
    {
      "name": null,
      "description": "Initial consultation with trainer",
      "durationMinutes": 45,
      "price": 20
    },
    {
      "name": "John Doe",
      "description": "Advanced training session",
      "durationMinutes": 120,
      "price": 100
    },
    {
      "name": "Jane Smith",
      "description": "Group training session",
      "durationMinutes": 75,
      "price": 40
    },
    {
      "name": "Alice Johnson",
      "description": "Yoga session",
      "durationMinutes": 60,
      "price": 30
    },
    {
      "name": "Bob Brown",
      "description": "Pilates session",
      "durationMinutes": 50,
      "price": 25
    },
    {
      "name": "Charlie Davis",
      "description": "Cardio session",
      "durationMinutes": 45,
      "price": 20
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200, // Adjust the height as needed
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg'),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ExpansionTile(
                      title: Text(
                        appointment['name'] ?? 'No name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Duration: ${appointment['durationMinutes']} minutes\nPrice: \$${appointment['price']}',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment['description'] ?? 'No description',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle join class button press
                                },
                                child: const Text('Join Class'),
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