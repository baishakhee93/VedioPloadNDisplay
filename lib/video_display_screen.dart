import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoDisplayScreen extends StatefulWidget {
  final String videoPath;

  VideoDisplayScreen({required this.videoPath});

  @override
  _VideoDisplayScreenState createState() => _VideoDisplayScreenState();
}

class _VideoDisplayScreenState extends State<VideoDisplayScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    await _videoPlayerController.initialize();
    setState(() {});
    _videoPlayerController.play();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Video'),
      ),
      body: Center(
        child: _videoPlayerController.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController),
        )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _videoPlayerController.value.isPlaying
                ? _videoPlayerController.pause()
                : _videoPlayerController.play();
          });
        },
        child: Icon(
          _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
