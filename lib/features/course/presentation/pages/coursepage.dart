import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/muscle_group.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/subscription_plan.dart';
import 'package:gym_fitness_mobile/features/course/presentation/pages/muscle_group_detail_page.dart';
import 'package:video_player/video_player.dart'; // Add this import

import '../../../../core/network/endpoints/workout_plan.dart';
import '../../../../core/network/endpoints/workout_plan_exercise.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/endpoints/payment.dart';

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
                            child:
                                _buildCategoryCard(group.name, group.imageUrl),
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
        final muscleGroup =
            muscleGroups.firstWhere((group) => group.name == title);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MuscleGroupDetailPage(muscleGroup: muscleGroup),
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

  Widget _buildSubscriptionPlanItem(
      BuildContext context, SubscriptionPlan plan) {
    return GestureDetector(
      onTap: () async {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: CircularProgressIndicator());
            },
          );

          // Fetch detailed plan data
          final detailedPlan = await _subscriptionPlanApiService
              .getSubscriptionPlanById(plan.subscriptionPlanId);

          // Hide loading indicator
          Navigator.pop(context);

          // Navigate to detail page with detailed plan data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(plan: detailedPlan),
            ),
          );
        } catch (e) {
          // Hide loading indicator
          Navigator.pop(context);

          // Show error message
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
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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

class _CourseDetailPageState extends State<CourseDetailPage>
    with SingleTickerProviderStateMixin {
  final WorkoutPlanApiService _workoutPlanApiService =
      WorkoutPlanApiService(DioClient());
  final WorkoutPlanExerciseApiService _workoutPlanExerciseApiService =
      WorkoutPlanExerciseApiService(DioClient());
  final PaymentApiService _paymentApiService = PaymentApiService(DioClient());

  bool isExpanded = false;
  String? playingVideoUrl; // Add state to track the currently playing video
  VideoPlayerController? _videoController; // Add video controller
  bool _showControls = false; // Track visibility of video controls
  Timer? _hideControlsTimer; // Timer to hide controls after inactivity
  AnimationController?
      _animationController; // Controller for spinning animation

 bool _hasProcessedInitialUri = false; // Add this flag

  @override
  void initState() {
    super.initState();
    
    // Initialize AppLinks
    final appLinks = AppLinks();
    
    // Listen to incoming links
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('🔷 Incoming URI: $uri');
        _handlePayPalReturn(uri);
      }
    }, onError: (err) {
      print('❌ Error handling URI: $err');
    });

    // Check for initial URI only once
    if (!_hasProcessedInitialUri) {
      appLinks.getInitialLink().then((Uri? uri) {
        if (uri != null) {
          print('🔷 Initial URI: $uri');
          _handlePayPalReturn(uri);
          _hasProcessedInitialUri = true;
        }
      });
    }
  }

      void _handlePayPalReturn(Uri uri) async {
        // Add check to prevent duplicate processing
    if (!mounted || !uri.queryParameters.containsKey('paymentId') || !uri.queryParameters.containsKey('PayerID')) {
      return;
    }
    if (uri.scheme == 'gymfitness' && uri.host == 'paypal-return') {
      try {
        final paymentId = uri.queryParameters['paymentId'];
        final payerId = uri.queryParameters['PayerID'];
        
        print('🔷 Payment ID: $paymentId');
        print('🔷 Payer ID: $payerId');
        print('🛣️ Attempting to navigate to: ${AppRoutes.paymentSuccess}');

        if (paymentId != null && payerId != null && mounted) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: CircularProgressIndicator());
            },
          );

          try {
            await _paymentApiService.executePayment(
              paymentId: paymentId,
              payerId: payerId,
              subscriptionId: widget.plan.subscriptionId.toString(),
            );

            if (!mounted) return;

            // Hide loading dialog
            Navigator.pop(context);

            print('🛣️ Attempting to navigate to: ${AppRoutes.paymentSuccess}');
            // Navigate to payment success page instead of main screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.paymentSuccess,
              (route) => false,
            ).then((_) {
              print('🛣️ Navigation to success page completed');
            }).catchError((error) {
              print('❌ Navigation error: $error');
            });
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context);
            throw e;
          }
        }
      } catch (e) {
        print('🔷 Error executing payment: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing payment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoController?.dispose(); // Dispose video controller
    _animationController?.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.plan.name),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 200), // Leave space for the sticky video
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Plan Details
                        Text(
                          'Chi tiết gói tập',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.plan.description),
                        Text(
                          'Giá: ${widget.plan.price} đ',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        Text('Thời hạn: ${widget.plan.durationMonths} tháng'),

                        const SizedBox(height: 20),

                        // Workout Plans
                        Text(
                          'Chương trình tập',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                              subtitle:
                                  Text('${workoutPlan.durationWeeks} tuần'),
                              onExpansionChanged: (expanded) async {
                                if (expanded) {
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      },
                                    );

                                    // Lấy chi tiết workout plan
                                    final workoutPlanDetail =
                                        await _workoutPlanApiService
                                            .getWorkoutPlanById(
                                                workoutPlan.planId);

                                    // Lấy chi tiết từng bài tập trong workout plan
                                    List<WorkoutPlanExercise> updatedExercises =
                                        [];
                                    for (var exercise in workoutPlanDetail
                                        .workoutPlanExercises) {
                                      final exerciseDetail =
                                          await _workoutPlanExerciseApiService
                                              .getWorkoutPlanExerciseById(
                                                  exercise.planId);
                                      updatedExercises.add(exerciseDetail);
                                    }

                                    // Cập nhật lại danh sách bài tập trong workout plan
                                    final updatedWorkoutPlan =
                                        workoutPlanDetail.copyWith(
                                            workoutPlanExercises:
                                                updatedExercises);

                                    Navigator.pop(context);

                                    setState(() {
                                      widget.plan.workoutPlans[index] =
                                          updatedWorkoutPlan;
                                    });
                                  } catch (e) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error loading workout details: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Mô tả: ${workoutPlan.description}'),
                                      Text(
                                          'Đối tượng: ${workoutPlan.targetAudience}'),
                                      Text('Mục tiêu: ${workoutPlan.goals}'),
                                      Text(
                                          'Yêu cầu: ${workoutPlan.prerequisites}'),
                                      const SizedBox(height: 8),

                                      // Exercises
                                      Text(
                                        'Bài tập',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: workoutPlan
                                            .workoutPlanExercises.length,
                                        itemBuilder: (context, exerciseIndex) {
                                          final exerciseDetail =
                                              workoutPlan.workoutPlanExercises[
                                                  exerciseIndex];

                                          return ListTile(
                                            leading: exerciseDetail
                                                        .exercise?.imageUrl !=
                                                    null
                                                ? Image.network(
                                                    exerciseDetail.exercise
                                                            .imageUrl ??
                                                        'https://example.com/default-image.png',
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                            title: Text(exerciseDetail
                                                    .exercise?.name ??
                                                'Exercise ${exerciseDetail.exerciseId}'),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Tuần ${exerciseDetail.weekNumber}, Ngày ${exerciseDetail.dayOfWeek}'),
                                                Text(
                                                    '${exerciseDetail.sets} sets x ${exerciseDetail.reps} reps'),
                                                Text(
                                                    'Nghỉ: ${exerciseDetail.restTimeSeconds}s'),
                                                if (exerciseDetail
                                                    .notes.isNotEmpty)
                                                  Text(
                                                      'Ghi chú: ${exerciseDetail.notes}'),
                                              ],
                                            ),
                                            trailing: exerciseDetail
                                                        .exercise?.videoUrl !=
                                                    null
                                                ? _buildPlayButtonWithSpinner(
                                                    exerciseDetail)
                                                : null,
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
                            onPressed: () async {
                              try {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                );

                                // Create subscription request
                                final request = SubscriptionRequest(
                                  subscriptionPlanId:
                                      widget.plan.subscriptionPlanId,
                                  paymentFrequency:
                                      'Monthly', // You can make this configurable
                                  autoRenew:
                                      true, // You can make this configurable
                                );

                                // Call subscribe endpoint
                                final response =
                                    await _paymentApiService.subscribe(request);

                                // Store the subscriptionId in a variable
                                final subscriptionId =
                                    response['subscriptionId']?.toString();

                                // Open payment URL in browser
                                if (response != null &&
                                    response['paymentUrl'] != null) {
                                  final Uri url =
                                      Uri.parse(response['paymentUrl']);
                                  if (await canLaunchUrl(url)) {
                                    // Store subscriptionId for later use
                                    setState(() {
                                      widget.plan.subscriptionId =
                                          int.parse(subscriptionId!);
                                    });

                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.platformDefault,
                                    );
                                  } else {
                                    throw 'Could not launch payment URL';
                                  }
                                }

                                // Hide loading indicator
                                Navigator.pop(context);

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please complete your payment in the browser'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Don't navigate back immediately
                                // Navigator.pop(context);
                              } catch (e) {
                                // Hide loading indicator
                                Navigator.pop(context);

                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error subscribing: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Đăng ký ngay',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (playingVideoUrl != null) // Sticky video player
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _toggleControls,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio:
                          _videoController?.value.aspectRatio ?? 16 / 9,
                      child: _videoController != null &&
                              _videoController!.value.isInitialized
                          ? VideoPlayer(_videoController!)
                          : Center(child: CircularProgressIndicator()),
                    ),
                    if (_showControls && _videoController != null)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_videoController!.value.isPlaying) {
                                        _videoController!.pause();
                                      } else {
                                        _videoController!.play();
                                      }
                                    });
                                    _startHideControlsTimer();
                                  },
                                ),
                                Text(
                                  '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.replay,
                                      color: Colors.white),
                                  onPressed: () {
                                    _videoController!
                                        .seekTo(Duration.zero); // Replay video
                                    _videoController!.play();
                                    _startHideControlsTimer();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _videoController?.pause(); // Pause video
                            playingVideoUrl = null; // Stop playing video
                          });
                        },
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

  Widget _buildPlayButtonWithSpinner(WorkoutPlanExercise exerciseDetail) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (playingVideoUrl == exerciseDetail.exercise?.videoUrl)
          RotationTransition(
            turns: _animationController!,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
          ),
        IconButton(
          icon: Icon(Icons.play_arrow, color: Colors.blue),
          onPressed: () {
            setState(() {
              playingVideoUrl = exerciseDetail.exercise?.videoUrl; // Play video
              _videoController = VideoPlayerController.networkUrl(
                Uri.parse(playingVideoUrl!),
              )..initialize().then((_) {
                  setState(() {
                    _videoController?.play(); // Start video
                  });
                });
            });
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// Add a widget for video controls
class VideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoControls({Key? key, required this.controller}) : super(key: key);

  @override
  _VideoControlsState createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VideoProgressIndicator(
          widget.controller,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: Colors.blue,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.black,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  if (widget.controller.value.isPlaying) {
                    widget.controller.pause();
                  } else {
                    widget.controller.play();
                  }
                });
              },
            ),
            Text(
              '${_formatDuration(widget.controller.value.position)} / ${_formatDuration(widget.controller.value.duration)}',
              style: TextStyle(color: Colors.black),
            ),
            IconButton(
              icon: Icon(Icons.replay, color: Colors.blue),
              onPressed: () {
                widget.controller.seekTo(Duration.zero); // Replay video
                widget.controller.play();
              },
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// Add a reusable widget for video playback
class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Video Player Placeholder\n$videoUrl',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
