import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/muscle_group.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/subscription_plan.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/user_subscription.dart';
import 'package:gym_fitness_mobile/features/course/presentation/pages/course_detail_page.dart';
import 'package:gym_fitness_mobile/features/course/presentation/pages/muscle_group_detail_page.dart';
import 'package:gym_fitness_mobile/features/course/presentation/pages/video_course_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String selectedCategory = 'My Course';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<SubscriptionPlan> subscriptionPlans = [];
  bool isLoadingPlans = true;
  List<MuscleGroup> muscleGroups = [];
  bool isLoadingMuscleGroups = true;
  List<UserSubscription> userSubscriptions = [];
  bool isLoadingUserSubscriptions = true;

  final MuscleGroupApiService _muscleGroupApiService = MuscleGroupApiService(DioClient());
  final SubscriptionPlanApiService _subscriptionPlanApiService = SubscriptionPlanApiService(DioClient());
  final UserSubscriptionApiService _userSubscriptionApiService = UserSubscriptionApiService(DioClient());

  String userEmail = 'Không có email'; // Lưu email lấy từ SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    fetchMuscleGroups();
    fetchSubscriptionPlans();
    fetchUserSubscriptions();
    _searchController.addListener(_filterBySearchQuery);
  }

  Future<void> _loadUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    userEmail = prefs.getString('userEmail') ?? 'Không có email';
  });

  if (userEmail.isNotEmpty && userEmail != 'Không có email') {
    fetchUserSubscriptions();
  }
}


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBySearchQuery() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
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
      final plans = await _subscriptionPlanApiService.getSubscriptionPlans();
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

  Future<void> fetchUserSubscriptions() async {
  if (userEmail.isEmpty || userEmail == 'Không có email') {
    print('User email is invalid, skipping API call');
    setState(() {
      isLoadingUserSubscriptions = false;
    });
    return;
  }

  try {
    final subscriptions = await _userSubscriptionApiService.getUserSubscriptions(userEmail);
    setState(() {
      userSubscriptions = subscriptions;
      isLoadingUserSubscriptions = false;
    });
  } catch (e) {
    print('Error fetching user subscriptions: $e');
    setState(() {
      isLoadingUserSubscriptions = false;
    });
  }
}


  void filterCourses(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách gói tập cho "All Course"
    final displayedPlans = subscriptionPlans.where((plan) {
      final matchesCategory = plan.isActive;
      final matchesSearch = searchQuery.isEmpty ||
          plan.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Lọc danh sách gói tập của người dùng cho "My Course"
    final displayedUserSubscriptions = userSubscriptions.where((subscription) {
      final matchesSearch = searchQuery.isEmpty ||
          subscription.subscriptionPlanName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Tính số lượng gói tập được tìm thấy
    final foundCount = selectedCategory == 'My Course'
        ? displayedUserSubscriptions.length
        : displayedPlans.length;

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
                            child: _buildCategoryCard(group.name, group.imageUrl),
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
                  _buildFilterButton('My Course',
                      isSelected: selectedCategory == 'My Course'),
                  _buildFilterButton('All Course',
                      isSelected: selectedCategory == 'All Course'),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tìm thấy $foundCount gói tập',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: selectedCategory == 'My Course'
                    ? isLoadingUserSubscriptions
                        ? Center(child: CircularProgressIndicator())
                        : displayedUserSubscriptions.isEmpty
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
                                itemCount: displayedUserSubscriptions.length,
                                itemBuilder: (context, index) {
                                  return _buildUserSubscriptionItem(
                                      context, displayedUserSubscriptions[index]);
                                },
                              )
                    : isLoadingPlans
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
                                  return _buildSubscriptionPlanItem(
                                      context, displayedPlans[index]);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imageUrl) {
    return GestureDetector(
      onTap: () {
        final muscleGroup = muscleGroups.firstWhere((group) => group.name == title);
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
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.7),
                ),
              ],
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
      onTap: () async {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: CircularProgressIndicator());
            },
          );

          final detailedPlan = await _subscriptionPlanApiService
              .getSubscriptionPlanById(plan.subscriptionPlanId);

          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(plan: detailedPlan),
            ),
          );
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading plan details: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  Widget _buildUserSubscriptionItem(BuildContext context, UserSubscription subscription) {
  return GestureDetector(
    onTap: () async {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final detailedPlan = await _subscriptionPlanApiService
            .getSubscriptionPlanById(subscription.subscriptionPlanId);

        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCoursePage(plan: detailedPlan),
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading plan details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          subscription.subscriptionPlanName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start: ${subscription.startDate.toString().split(' ')[0]}'),
            Text('End: ${subscription.endDate.toString().split(' ')[0]}'),
          ],
        ),
        trailing: Text(
          subscription.status,
          style: TextStyle(
            color: subscription.status == 'Active' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}}