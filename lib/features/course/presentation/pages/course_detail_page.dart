import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/subscription_plan.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/endpoints/workout_plan.dart';
import '../../../../core/network/endpoints/workout_plan_exercise.dart';
import '../../../../core/network/endpoints/payment.dart';

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
  String? playingVideoUrl;
  VideoPlayerController? _videoController;
  bool _showControls = false;
  Timer? _hideControlsTimer;
  AnimationController? _animationController;

  bool _hasProcessedInitialUri = false;

  @override
  void initState() {
    super.initState();
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handlePayPalReturn(uri);
      }
    }, onError: (err) {
      print('❌ Error handling URI: $err');
    });

    if (!_hasProcessedInitialUri) {
      appLinks.getInitialLink().then((Uri? uri) {
        if (uri != null) {
          _handlePayPalReturn(uri);
          _hasProcessedInitialUri = true;
        }
      });
    }
  }

  void _handlePayPalReturn(Uri uri) async {
    if (!mounted ||
        !uri.queryParameters.containsKey('paymentId') ||
        !uri.queryParameters.containsKey('PayerID') ||
        widget.plan.subscriptionId.toString() == "0") {
      return;
    }
    if (uri.scheme == 'gymfitness' && uri.host == 'paypal-return') {
      try {
        final paymentId = uri.queryParameters['paymentId'];
        final payerId = uri.queryParameters['PayerID'];

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

            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.paymentSuccess,
              (route) => false,
            ).catchError((error) {
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
    _videoController?.dispose();
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
              padding: const EdgeInsets.only(top: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              title: Text('${workoutPlan.name}'),
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

                                    final workoutPlanDetail =
                                        await _workoutPlanApiService
                                            .getWorkoutPlanById(
                                                workoutPlan.planId);

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
                                                ? Icon(
                                                    Icons.lock,
                                                    color: Colors.grey,
                                                  )
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
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                );

                                final request = SubscriptionRequest(
                                  subscriptionPlanId:
                                      widget.plan.subscriptionPlanId,
                                  paymentFrequency: 'Monthly',
                                  autoRenew: true,
                                );

                                final response =
                                    await _paymentApiService.subscribe(request);

                                final subscriptionId =
                                    response['subscriptionId']?.toString();

                                if (response != null &&
                                    response['paymentUrl'] != null) {
                                  final Uri url =
                                      Uri.parse(response['paymentUrl']);
                                  if (await canLaunchUrl(url)) {
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

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please complete your payment in the browser'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context);
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
        ],
      ),
    );
  }
}