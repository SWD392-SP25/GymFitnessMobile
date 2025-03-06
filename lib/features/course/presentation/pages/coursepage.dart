import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String selectedCategory = 'All';
  final List<Map<String, dynamic>> allCourses = [
    {
      'title': 'Product Design v1.0',
      'about':'set up persipiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo',
      'author': 'Robertson Connie',
      'price': 1900000,
      'duration': '16 hours',
      'category': 'Popular',
      'lessons': [
        {'title': 'Introduction', 'duration': '10', 'locked': false},
        {'title': 'UI/UX Principles', 'duration': '12', 'locked': false},
        {'title': 'Final Project', 'duration': '15', 'locked': true},
      ]
    },
    {
      'title': 'Flutter Development',
      'about':'set up persipiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo',
      'author': 'Jane Doe',
      'price': 2000000,
      'duration': '15 hours',
      'category': 'New',
      'lessons': [
        {'title': 'Flutter Basics', 'duration': '20', 'locked': false},
        {'title': 'State Management', 'duration': '30', 'locked': false},
        {'title': 'Advanced UI', 'duration': '40', 'locked': true},
      ]
    },
  ];

  List<Map<String, dynamic>> filteredCourses = [];

  @override
  void initState() {
    super.initState();
    filteredCourses = allCourses;
  }

  void filterCourses(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredCourses = allCourses;
      } else {
        filteredCourses = allCourses.where((course) => course['category'] == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text(
            'Course',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.black),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.tune, color: Colors.grey),
                  hintText: 'Find Course',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryCard('Tên Cơ', Colors.blue),
                  _buildCategoryCard('Tên cơ2', Colors.purple),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Choice Your Course',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFilterButton('All', isSelected: selectedCategory == 'All'),
                  _buildFilterButton('Popular', isSelected: selectedCategory == 'Popular'),
                  _buildFilterButton('New', isSelected: selectedCategory == 'New'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: filteredCourses.map((course) => _buildCourseItem(context, course)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, Color color) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          filterCourses(title);
        },
        child: Text(title),
      ),
    );
  }

  Widget _buildCourseItem(BuildContext context, Map<String, dynamic> course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(course: {
              'title': course['title'],
              'about': course['about'],
              'author': course['author'],
              'price': course['price'],
              'duration': course['duration'],
              'lessons': course['lessons'] ?? [], // Ensure lessons always exist
            }),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: Text(course['title'], style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(course['author']),
          trailing: Text(
            "${course['price']} đ",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseDetailPage({super.key, required this.course});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header with illustration image
          Container(
            height: screenHeight * 2, // Adjust height based on screen size
            decoration: const BoxDecoration(
              color: Colors.brown,
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: screenHeight * 0.5),
              child: Center(
                child: Image.asset(
                  'assets/images/welcome/welcome.png', // Replace with your illustration image
                  height: screenHeight * 0.5, // Adjust image height based on screen size
                ),
              ),
            ),
          ),

          // Course content
          Positioned(
            top: screenHeight * 0.4, // Adjust this value to control how much the image is covered
            left: 0,
            right: 0,
            bottom: 0, // Ensure the content takes up the remaining space
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.course['title'] ?? 'No title',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${widget.course['price']} đ",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${widget.course['duration']} • ${widget.course['lessons'].length} Lessons",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // About this course
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'About this course',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course['about'] ?? 'No description available',
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Text(isExpanded ? 'View less' : 'View more'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Lessons list
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: (widget.course['lessons'] ?? []).length, // Ensure lessons is not null
                        itemBuilder: (context, index) {
                          final lesson = widget.course['lessons'][index] ?? {}; // Avoid null

                          return ListTile(
                            leading: Text(
                              (index + 1).toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            title: Text(lesson['title'] ?? 'No Title'), // Avoid null title
                            subtitle: Text("${lesson['duration'] ?? 'Unknown'} mins"),
                            trailing: (lesson['locked'] ?? false)
                                ? const Icon(Icons.lock, color: Colors.grey)
                                : const Icon(Icons.play_circle_fill, color: Colors.blue),
                            onTap: (lesson['locked'] ?? false) ? null : () {
                              // Handle lesson tap
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Buy Now button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          // Handle course purchase
                        },
                        child: const Text('Buy Now', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}