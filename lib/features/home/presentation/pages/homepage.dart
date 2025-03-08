import 'package:flutter/material.dart';
import 'widgets/meetup_card.dart';
import 'widgets/training_item.dart';
import 'widgets/course_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4A43EC);
    const textColor = Colors.white;
    const progressBackgroundColor = Color(0xFFE1E3FD);

    // danh sách course
    final List<Map<String, String>> myCourses = [
      {
        'title': 'Flutter Basics',
        'buttonText': 'Start',
        'backgroundImage': 'assets/course_1.png',
      },
      {
        'title': 'Advanced Dart',
        'buttonText': 'Continue',
        'backgroundImage': 'assets/course_2.png',
      },
      {
        'title': 'UI/UX Design',
        'buttonText': 'View',
        'backgroundImage': 'assets/course_3.png',
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
          ),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, Kristin',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Let's start training",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Positioned(
                        right: 0,
                        top: 0,
                        child: const CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage('assets/avatar.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Learned today',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                            ),
                            const Spacer(),
                            Text(
                              'My courses',
                              style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '46min / 60min',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 46 / 60,
                            minHeight: 8,
                            backgroundColor: progressBackgroundColor,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                //my course
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Courses',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      myCourses.isEmpty
                          ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Get started with a new course!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                          : SizedBox(
                        height: 130,// độ cao của course card
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: myCourses.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: CourseCard(
                                title: myCourses[index]['title']!,
                                buttonText: myCourses[index]['buttonText']!,
                                backgroundImage: myCourses[index]['backgroundImage']!,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // training plan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Training Plan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TrainingItem(title: 'Tên khoá học 1', current: 40, total: 48),
                      TrainingItem(title: 'Tên khoá học 2', current: 6, total: 24),
                      const SizedBox(height: 24),
                      const MeetupCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
