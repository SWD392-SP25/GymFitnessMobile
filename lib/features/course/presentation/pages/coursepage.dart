import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> courses = [//để data tạm tại chưa biết call api như nào
    {'title': 'Product Design v1.0', 'author': 'Robertson Connie', 'price': 190, 'duration': '16 hours', 'category': 'Popular'},
    {'title': 'Java Development', 'author': 'Nguyen Shane', 'price': 190, 'duration': '16 hours', 'category': 'New'},
    {'title': 'Visual Design', 'author': 'Bert Pullman', 'price': 250, 'duration': '14 hours', 'category': 'Popular'},
    {'title': 'Flutter Development', 'author': 'Jane Doe', 'price': 200, 'duration': '15 hours', 'category': 'New'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
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
                children: courses.where((course) => selectedCategory == 'All' || course['category'] == selectedCategory).map((course) => _buildCourseItem(
                    course['title'], course['author'], course['price'], course['duration']
                )).toList(),
              ),
            ),
          ],
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
          setState(() {
            selectedCategory = title;
          });
        },
        child: Text(title),
      ),
    );
  }

  Widget _buildCourseItem(String title, String author, int price, String duration) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(author, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duration,
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
