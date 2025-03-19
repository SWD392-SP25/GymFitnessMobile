import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/muscle_group.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/subscription_plan.dart';
import 'package:gym_fitness_mobile/features/course/presentation/pages/muscle_group_detail_page.dart';

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
      final data = await _muscleGroupApiService.getMuscleGroups();
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
    // Find the corresponding muscle group
    final muscleGroup = muscleGroups.firstWhere((group) => group.name == title);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MuscleGroupDetailPage(muscleGroup: muscleGroup),
          ),
        );
      },
      child: Container(
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
            builder: (context) => CourseDetailPage(plan: plan),
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
  final SubscriptionPlan plan;
  const CourseDetailPage({super.key, required this.plan});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.plan.name),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Details
              Text(
                'Chi tiết gói tập',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.plan.description),
              Text(
                'Giá: ${widget.plan.price} đ',
                style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              Text('Thời hạn: ${widget.plan.durationMonths} tháng'),
              
              const SizedBox(height: 20),
              
              // Workout Plans
              Text(
                'Chương trình tập',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.plan.workoutPlans.length,
                itemBuilder: (context, index) {
                  final workoutPlan = widget.plan.workoutPlans[index];
                  return ExpansionTile(
                    title: Text(workoutPlan.name),
                    subtitle: Text('${workoutPlan.durationWeeks} tuần'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mô tả: ${workoutPlan.description}'),
                            Text('Đối tượng: ${workoutPlan.targetAudience}'),
                            Text('Mục tiêu: ${workoutPlan.goals}'),
                            Text('Yêu cầu: ${workoutPlan.prerequisites}'),
                            const SizedBox(height: 8),
                            
                            // Exercises
                            Text(
                              'Bài tập',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: workoutPlan.workoutPlanExercises.length,
                              itemBuilder: (context, exerciseIndex) {
                                final exerciseDetail = workoutPlan.workoutPlanExercises[exerciseIndex];
                                return ListTile(
                                  title: Text(exerciseDetail.exercise.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Tuần ${exerciseDetail.weekNumber}, Ngày ${exerciseDetail.dayOfWeek}'),
                                      Text('${exerciseDetail.sets} sets x ${exerciseDetail.reps} reps'),
                                      Text('Nghỉ: ${exerciseDetail.restTimeSeconds}s'),
                                      if (exerciseDetail.notes.isNotEmpty)
                                        Text('Ghi chú: ${exerciseDetail.notes}'),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              // Buy Now button
              const SizedBox(height: 20),
              SizedBox(
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
                    // Handle subscription purchase
                  },
                  child: const Text(
                    'Đăng ký ngay',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
