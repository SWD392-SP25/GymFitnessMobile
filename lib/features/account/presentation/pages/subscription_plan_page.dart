import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/subscription_plan.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/workout_plan.dart';
import 'package:gym_fitness_mobile/features/account/presentation/pages/video_page.dart';

class SubscriptionPlanPage extends StatefulWidget {
  const SubscriptionPlanPage({super.key});

  @override
  _SubscriptionPlanPageState createState() => _SubscriptionPlanPageState();
}

class _SubscriptionPlanPageState extends State<SubscriptionPlanPage> {
  String selectedCategory = 'All';
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  List<SubscriptionPlan> subscriptionPlans = [];
  bool isLoading = true;

  final SubscriptionPlanApiService _subscriptionPlanApiService =
      SubscriptionPlanApiService(DioClient());

  Map<int, List<WorkoutPlan>> workoutPlansMap = {};

  final WorkoutPlanApiService _workoutPlanApiService =
      WorkoutPlanApiService(DioClient());

  @override
  void initState() {
    super.initState();
    fetchSubscriptionPlans();
    _searchController.addListener(_filterBySearchQuery);
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

  Future<void> fetchSubscriptionPlans() async {
    try {
      final plans = await _subscriptionPlanApiService.getSubscriptionPlans();
      setState(() {
        subscriptionPlans = plans;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching subscription plans: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchWorkoutPlans(int subscriptionPlanId) async {
    try {
      print('Fetching workout plans for subscription $subscriptionPlanId');
      final response = await _workoutPlanApiService.getWorkoutPlans();
      print('Raw Workout Plans API Response: ${response.runtimeType}');

      if (response is List<WorkoutPlan>) {
        // ✅ Nếu API đã trả về List<WorkoutPlan, không cần parse lại
        print('API trả về danh sách WorkoutPlan, không cần parse JSON');
        final filteredPlans = response
            .where((plan) => plan.subscriptionPlanId == subscriptionPlanId)
            .toList();

        setState(() {
          workoutPlansMap[subscriptionPlanId] = filteredPlans;
        });

        print('Filtered Workout Plans: $filteredPlans');
      } else if (response is List) {
        // ✅ Nếu API trả về List<Map<String, dynamic>>, thì mới cần parse
        print('API trả về List<Map<String, dynamic>>, cần parse JSON');
        final parsedPlans = response
            .map((rawPlan) =>
                WorkoutPlan.fromJson(rawPlan as Map<String, dynamic>))
            .where((plan) => plan.subscriptionPlanId == subscriptionPlanId)
            .toList();

        setState(() {
          workoutPlansMap[subscriptionPlanId] = parsedPlans;
        });

        print('Parsed Workout Plans: $parsedPlans');
      } else {
        print('Error: API response is not a valid list. Response: $response');
      }
    } catch (e) {
      print(
          'Error fetching workout plans for subscription $subscriptionPlanId: $e');
    }
  }

  WorkoutPlan? _parseWorkoutPlan(dynamic rawPlan) {
    try {
      if (rawPlan is Map<String, dynamic>) {
        return WorkoutPlan.fromJson(rawPlan);
      } else {
        print('Warning: Invalid workout plan format: $rawPlan');
        return null;
      }
    } catch (e) {
      print('Error parsing workout plan: $e');
      return null;
    }
  }

  void filterByStatus(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedPlans = subscriptionPlans.where((plan) {
      final matchesCategory = selectedCategory == 'All' ||
          (plan.isActive ? 'Active' : 'Inactive') == selectedCategory;
      final matchesSearch =
          searchQuery.isEmpty || plan.name.toLowerCase().contains(searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gói tập của bạn"),
        backgroundColor: Colors.white,
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
            Row(
              children: [
                _buildFilterButton('All', selectedCategory == 'All'),
                _buildFilterButton('Active', selectedCategory == 'Active'),
                _buildFilterButton('Inactive', selectedCategory == 'Inactive'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayedPlans.isEmpty
                      ? _buildEmptyState()
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
    );
  }

  Widget _buildFilterButton(String title, bool isSelected) {
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
          filterByStatus(title);
        },
        child: Text(title),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("Không tìm thấy gói tập nào",
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlanItem(
      BuildContext context, SubscriptionPlan plan) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(plan.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${plan.durationMonths} tháng'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text("${plan.price} đ",
            //     style: const TextStyle(
            //         color: Colors.blue, fontWeight: FontWeight.bold)),
            // Text(plan.isActive ? "Active" : "Inactive",
            //     style: TextStyle(
            //         color: plan.isActive ? Colors.green : Colors.red,
            //         fontSize: 12)),
          ],
        ),
        onExpansionChanged: (isExpanded) {
          if (isExpanded &&
              !workoutPlansMap.containsKey(plan.subscriptionPlanId)) {
            fetchWorkoutPlans(plan.subscriptionPlanId);
          }
        },
        children: workoutPlansMap[plan.subscriptionPlanId]?.map((workoutPlan) {
              return _buildWorkoutPlanItem(workoutPlan);
            }).toList() ??
            [const Center(child: CircularProgressIndicator())],
      ),
    );
  }

  Widget _buildWorkoutPlanItem(WorkoutPlan workoutPlan) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📖 Mô tả: ${workoutPlan.description}'),
          Text('👥 Đối tượng: ${workoutPlan.targetAudience}'),
          Text('🎯 Mục tiêu: ${workoutPlan.goals}'),
          Text('⚠ Yêu cầu: ${workoutPlan.prerequisites}'),
          const SizedBox(height: 8),
          const Text(
            '💪 Danh sách bài tập',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workoutPlan.workoutPlanExercises.length,
            itemBuilder: (context, exerciseIndex) {
              final exerciseDetail =
                  workoutPlan.workoutPlanExercises[exerciseIndex];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          exerciseDetail.exercise.imageUrl != null
                              ? Image.network(
                                  exerciseDetail.exercise.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fitness_center, size: 50),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              exerciseDetail.exercise.name ?? '',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '🗓 Tuần ${exerciseDetail.weekNumber}, Ngày ${exerciseDetail.dayOfWeek}'),
                      Text(
                          '🛑 ${exerciseDetail.sets} sets x ${exerciseDetail.reps} reps'),
                      Text('⏳ Nghỉ: ${exerciseDetail.restTimeSeconds}s'),
                      if (exerciseDetail.notes.isNotEmpty)
                        Text('📌 Ghi chú: ${exerciseDetail.notes}'),
                      const SizedBox(height: 8),
                      if (exerciseDetail.exercise.videoUrl != null)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPage(exerciseDetail: exerciseDetail),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_circle_fill,
                              color: Colors.blue),
                          label: const Text("Xem Video"),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
