import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/muscle_group.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/subscription_plan.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String selectedCategory = 'All';
  String searchQuery = ''; // Add search query state
  
  // Text controller for search field
  final TextEditingController _searchController = TextEditingController();
  
  // Thay thế allCourses và filteredCourses bằng subscriptionPlans
  List<SubscriptionPlan> subscriptionPlans = [];
  List<SubscriptionPlan> filteredPlans = []; // Add filtered list
  bool isLoadingPlans = true;
  
  List<MuscleGroup> muscleGroups = [];
  bool isLoadingMuscleGroups = true;

  final MuscleGroupApiService _muscleGroupApiService =
      MuscleGroupApiService(DioClient());
  
  final SubscriptionPlanApiService _subscriptionPlanApiService =
      SubscriptionPlanApiService(DioClient());

  @override
  void initState() {
    super.initState();
    fetchMuscleGroups();
    fetchSubscriptionPlans();
    
    // Add listener to search controller
    _searchController.addListener(_filterBySearchQuery);
  }
  
  @override
  void dispose() {
    // Clean up controller when the widget is disposed
    _searchController.dispose();
    super.dispose();
  }

  // Filter plans based on search query
  void _filterBySearchQuery() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      searchQuery = query;
      // The filteredPlans will be computed in the build method
    });
  }

  Future<void> fetchMuscleGroups() async {
    try {
      final data = await _muscleGroupApiService.getMuscleGroup();
      setState(() {
        muscleGroups = data;
        isLoadingMuscleGroups = false;
      });
    } catch (e) {
      print('Error fetching muscle groups: $e');
      setState(() {
        isLoadingMuscleGroups = false;
      });
    }
  }
  
  Future<void> fetchSubscriptionPlans() async {
    try {
      print("🔷 Fetching subscription plans...");
      final plans = await _subscriptionPlanApiService.getSubscriptionPlans();
      print("🔷 Received ${plans.length} subscription plans");
      
      setState(() {
        subscriptionPlans = plans;
        isLoadingPlans = false;
      });
    } catch (e) {
      print('Error fetching subscription plans: $e');
      setState(() {
        isLoadingPlans = false;
      });
    }
  }

  void filterCourses(String category) {
    setState(() {
      selectedCategory = category;
      // Filtering is done in the build method
    });
  }

  @override
  Widget build(BuildContext context) {
    // Apply filters to get final list
    final displayedPlans = subscriptionPlans.where((plan) {
      // Apply category filter
      final matchesCategory = selectedCategory == 'All' || 
                             (plan.isActive ? 'Active' : 'Inactive') == selectedCategory;
      
      // Apply search filter
      final matchesSearch = searchQuery.isEmpty ||
                           plan.name.toLowerCase().contains(searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();

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
            'Gói tập',
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
              // Search field with controller
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ) 
                      : Icon(Icons.tune, color: Colors.grey),
                  hintText: 'Tìm gói tập',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: isLoadingMuscleGroups
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: muscleGroups.length,
                        itemBuilder: (context, index) {
                          final group = muscleGroups[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryCard(group.name, Colors.blue),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Chọn gói tập của bạn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFilterButton('All',
                      isSelected: selectedCategory == 'All'),
                  _buildFilterButton('Active',
                      isSelected: selectedCategory == 'Active'),
                  _buildFilterButton('Inactive',
                      isSelected: selectedCategory == 'Inactive'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Results count
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tìm thấy ${displayedPlans.length} gói tập',
                  style: TextStyle(
                    fontSize: 14, 
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              Expanded(
                child: isLoadingPlans
                    ? Center(child: CircularProgressIndicator())
                    : displayedPlans.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Không tìm thấy gói tập nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayedPlans.length,
                            itemBuilder: (context, index) {
                              return _buildSubscriptionPlanItem(context, displayedPlans[index]);
                            },
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

  Widget _buildSubscriptionPlanItem(BuildContext context, SubscriptionPlan plan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(
              course: {
                'title': plan.name,
                'about': plan.description,
                'author': '', // Không có thông tin tác giả
                'price': plan.price,
                'duration': '${plan.durationMonths} tháng',
                'lessons': [], // Không có bài học
                'status': plan.isActive ? 'Active' : 'Inactive',
              },
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: Text(
            plan.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${plan.durationMonths} tháng'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${plan.price} đ",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              Text(
                plan.isActive ? "Active" : "Inactive",
                style: TextStyle(
                  color: plan.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
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
              padding: EdgeInsets.only(
                  left: 16, right: 16, bottom: screenHeight * 0.5),
              child: Center(
                child: Image.asset(
                  'assets/images/welcome/welcome.png', // Replace with your illustration image
                  height: screenHeight *
                      0.5, // Adjust image height based on screen size
                ),
              ),
            ),
          ),

          // Course content
          Positioned(
            top: screenHeight *
                0.4, // Adjust this value to control how much the image is covered
            left: 0,
            right: 0,
            bottom: 0, // Ensure the content takes up the remaining space
            child: Container(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 30),
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
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${widget.course['price']} đ",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[800]),
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
                        itemCount: (widget.course['lessons'] ?? [])
                            .length, // Ensure lessons is not null
                        itemBuilder: (context, index) {
                          final lesson = widget.course['lessons'][index] ??
                              {}; // Avoid null

                          return ListTile(
                            leading: Text(
                              (index + 1).toString().padLeft(2, '0'),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            title: Text(lesson['title'] ??
                                'No Title'), // Avoid null title
                            subtitle:
                                Text("${lesson['duration'] ?? 'Unknown'} mins"),
                            trailing: (lesson['locked'] ?? false)
                                ? const Icon(Icons.lock, color: Colors.grey)
                                : const Icon(Icons.play_circle_fill,
                                    color: Colors.blue),
                            onTap: (lesson['locked'] ?? false)
                                ? null
                                : () {
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
                        child: const Text('Buy Now',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
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
