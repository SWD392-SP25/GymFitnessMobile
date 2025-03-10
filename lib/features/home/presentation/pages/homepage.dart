import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProgressBar(),
              const SizedBox(height: 20),
              _buildCourseCards(),
              const SizedBox(height: 20),
              _buildTrainingPlan(),
              const SizedBox(height: 20),
              _buildMeetupCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hi, Kristin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const Text(
              "Let's start training",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, color: Colors.blue),
        )
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Learned today', style: TextStyle(color: Colors.black54)),
              Text('46min / 60min', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Text('My courses', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buildCourseCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _courseCard('Tên khóa học', 'Get Started', Colors.orange),
        _courseCard('Khóa học khác', 'Learn More', Colors.blue),
      ],
    );
  }

  Widget _courseCard(String title, String buttonText, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color),
              onPressed: () {},
              child: Text(buttonText, style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Training Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _trainingItem('Tên khóa học 1', 40, 48),
        _trainingItem('Tên khóa học 2', 6, 24),
      ],
    );
  }

  Widget _trainingItem(String title, int progress, int total) {
    return ListTile(
      title: Text(title),
      subtitle: LinearProgressIndicator(value: progress / total, color: Colors.blue),
      trailing: Text('$progress/$total'),
    );
  }

  Widget _buildMeetupCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Meetup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text('Online exchange with PT', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}