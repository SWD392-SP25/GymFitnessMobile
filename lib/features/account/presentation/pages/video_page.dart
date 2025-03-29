import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/subscription_plan.dart';
import 'package:video_player/video_player.dart';
// Import model WorkoutPlanExercise (giả sử đã được định nghĩa trong project của bạn)

class VideoPage extends StatefulWidget {
  final WorkoutPlanExercise exerciseDetail;

  const VideoPage({Key? key, required this.exerciseDetail}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo VideoPlayerController với URL video từ đối tượng exerciseDetail
    _videoController =
        VideoPlayerController.network(widget.exerciseDetail.exercise.videoUrl)
          ..initialize().then((_) {
            // Video đã load xong, cần gọi setState để cập nhật UI
            setState(() {});
          });
    // Tùy chọn: không tự động phát khi mở trang (có thể bật autoPlay nếu muốn)
    _isPlaying = false;
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ của VideoPlayerController
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu bài tập từ exerciseDetail
    final exercise = widget.exerciseDetail.exercise;
    final week =
        widget.exerciseDetail.weekNumber; // Tuần của bài tập trong kế hoạch
    final day =
        widget.exerciseDetail.dayOfWeek; // Ngày của bài tập trong kế hoạch
    final sets = widget.exerciseDetail.sets;
    final reps = widget.exerciseDetail.reps;
    final rest = widget
        .exerciseDetail.restTimeSeconds; // Thời gian nghỉ giữa các hiệp (giây)
    final note = widget.exerciseDetail.notes; // Ghi chú (nếu có)

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vùng video với nền đen và trình phát
          Container(
            color: Colors.black87, // nền đen nhạt cho vùng video
            child: Center(
              child: _videoController.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        // Widget video player
                        AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        ),
                        // Nút Play/Pause ở giữa video
                        IconButton(
                          iconSize: 64.0,
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white70,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ],
                    )
                  : // Hiển thị vòng xoay chờ nếu video chưa tải xong
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
          // Phần thông tin mô tả bên dưới video
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên bài tập
                  Text(
                    exercise.name,
                    // style: Theme.of(context).textTheme.headline6,
                  ),
                  // Thông tin Tuần/Ngày
                  if (week != null && day != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Tuần $week - Ngày $day',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                  // Số hiệp x số lần
                  SizedBox(height: 8),
                  Text(
                    'Sets x Reps: ${sets} x ${reps}',
                    style: TextStyle(fontSize: 16),
                  ),
                  // Thời gian nghỉ giữa các hiệp
                  if (rest != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Nghỉ: ${rest}s',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                  // Ghi chú (nếu có)
                  if (note != null && note.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      'Ghi chú: $note',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
