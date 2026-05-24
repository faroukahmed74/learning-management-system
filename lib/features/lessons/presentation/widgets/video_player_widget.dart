import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.initialPositionSeconds = 0,
    this.onProgress,
  });

  final String url;
  final int initialPositionSeconds;
  final void Function(int positionSeconds, int durationSeconds)? onProgress;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      await videoController.initialize();

      if (widget.initialPositionSeconds > 0) {
        await videoController.seekTo(Duration(seconds: widget.initialPositionSeconds));
      }

      videoController.addListener(_handleProgress);

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        aspectRatio: videoController.value.aspectRatio,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.75, 1.0, 1.25, 1.5],
      );

      if (mounted) {
        setState(() {
          _videoController = videoController;
          _chewieController = chewieController;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  void _handleProgress() {
    final controller = _videoController;
    final callback = widget.onProgress;
    if (controller == null || callback == null || !controller.value.isInitialized) {
      return;
    }

    final position = controller.value.position.inSeconds;
    final duration = controller.value.duration.inSeconds;
    if (duration <= 0) return;

    callback(position, duration);
  }

  @override
  void dispose() {
    _videoController?.removeListener(_handleProgress);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Could not load video'),
        ),
      );
    }

    if (_chewieController == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
