import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/subscription_plan.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/endpoints/workout_plan.dart';
import '../../../../core/network/endpoints/workout_plan_exercise.dart';

class VideoCoursePage extends StatefulWidget {
  final SubscriptionPlan plan;
  const VideoCoursePage({super.key, required this.plan});

  @override
  _VideoCoursePageState createState() => _VideoCoursePageState();
}

class _VideoCoursePageState extends State<VideoCoursePage> {
  final WorkoutPlanApiService _workoutPlanApiService =
      WorkoutPlanApiService(DioClient());
  final WorkoutPlanExerciseApiService _workoutPlanExerciseApiService =
      WorkoutPlanExerciseApiService(DioClient());

  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  double _volume = 1.0; // Giá trị âm lượng mặc định (từ 0.0 đến 1.0)

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener); // Xóa listener
    _videoController?.dispose();
    super.dispose();
  }

  void _playVideo(String videoUrl) {
    if (_videoController != null) {
      _videoController!.removeListener(_videoListener); // Xóa listener cũ
      _videoController!.dispose();
    }
    _videoController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isPlaying = true;
          _videoController!.play();
          _videoController!.setVolume(_volume); // Áp dụng âm lượng khi phát
          _videoController!.addListener(_videoListener); // Thêm listener
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
  }

  // Listener để cập nhật thanh trượt thời gian
  void _videoListener() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        // Cập nhật giao diện, bao gồm thanh trượt thời gian
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  void _rewind() {
    final currentPosition = _videoController!.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _videoController!.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  void _forward() {
    final currentPosition = _videoController!.value.position;
    final duration = _videoController!.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _videoController!.seekTo(newPosition < duration ? newPosition : duration);
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      _videoController?.setVolume(volume); // Điều chỉnh âm lượng
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần phát video
          if (_isPlaying)
            Container(
              color: Colors.black,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                  // Nút điều khiển phát/tạm dừng và tua
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed: _rewind,
                      ),
                      IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        onPressed: _forward,
                      ),
                    ],
                  ),
                  // Thanh trượt thời gian
                  if (_videoController!.value.isInitialized)
                    Slider(
                      value: _videoController!.value.position.inSeconds.toDouble(),
                      min: 0.0,
                      max: _videoController!.value.duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        _videoController!.seekTo(Duration(seconds: value.toInt()));
                      },
                    ),
                  // Thanh trượt âm lượng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.volume_up, color: Colors.white),
                      SizedBox(
                        width: 200, // Giới hạn chiều rộng thanh trượt âm lượng
                        child: Slider(
                          value: _volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            _setVolume(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Chọn một bài tập để phát video',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          // Phần nội dung cuộn
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chương trình tập',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.plan.workoutPlans.length,
                      itemBuilder: (context, index) {
                        final workoutPlan = widget.plan.workoutPlans[index];
                        return ExpansionTile(
                          title: Text('${workoutPlan.name}'),
                          subtitle: Text('${workoutPlan.durationWeeks} tuần'),
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
                                        .getWorkoutPlanById(workoutPlan.planId);

                                List<WorkoutPlanExercise> updatedExercises = [];
                                for (var exercise
                                    in workoutPlanDetail.workoutPlanExercises) {
                                  final exerciseDetail =
                                      await _workoutPlanExerciseApiService
                                          .getWorkoutPlanExerciseById(
                                              exercise.planId);
                                  updatedExercises.add(exerciseDetail);
                                }

                                final updatedWorkoutPlan =
                                    workoutPlanDetail.copyWith(
                                        workoutPlanExercises: updatedExercises);

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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mô tả: ${workoutPlan.description}'),
                                  Text('Đối tượng: ${workoutPlan.targetAudience}'),
                                  Text('Mục tiêu: ${workoutPlan.goals}'),
                                  Text('Yêu cầu: ${workoutPlan.prerequisites}'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bài tập',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: workoutPlan
                                        .workoutPlanExercises.length,
                                    itemBuilder: (context, exerciseIndex) {
                                      final exerciseDetail = workoutPlan
                                          .workoutPlanExercises[exerciseIndex];
                                      return ListTile(
                                        leading: exerciseDetail
                                                    .exercise?.imageUrl !=
                                                null
                                            ? Image.network(
                                                exerciseDetail
                                                        .exercise!.imageUrl ??
                                                    'https://example.com/default-image.png',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        title: Text(exerciseDetail.exercise?.name ??
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
                                            if (exerciseDetail.notes.isNotEmpty)
                                              Text(
                                                  'Ghi chú: ${exerciseDetail.notes}'),
                                          ],
                                        ),
                                        trailing: exerciseDetail
                                                    .exercise?.videoUrl !=
                                                null
                                            ? IconButton(
                                                icon: const Icon(Icons.play_arrow,
                                                    color: Colors.blue),
                                                onPressed: () {
                                                  _playVideo(exerciseDetail
                                                      .exercise!.videoUrl!);
                                                },
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}