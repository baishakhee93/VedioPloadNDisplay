import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'video_display_screen.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoScreen(),
    );
  }
}

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  CameraController? _cameraController;
  XFile? _videoFile;
  final ImagePicker _picker = ImagePicker();
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isCameraInitialized = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    await _cameraController?.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _startRecording() async {
    if (!_isCameraInitialized) {
      await _initializeCamera();
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }


    await _cameraController?.startVideoRecording();
    setState(() {
      _isRecording = true;
      _hasRecorded = false;
    });
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }

    _videoFile = await _cameraController?.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
    });
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _videoFile = pickedFile;
      _navigateToVideoDisplayScreen();
    }
  }

  void _navigateToVideoDisplayScreen() {
    if (_videoFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoDisplayScreen(videoPath: _videoFile!.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video App'),
      ),
      body: Column(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized && _isRecording)
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _pickVideo,
                child: Text('Upload Video'),
              ),
            ],
          ),
          if (_hasRecorded)
            ElevatedButton(
              onPressed: _navigateToVideoDisplayScreen,
              child: Text('Display Recorded Video'),
            ),
        ],
      ),
    );
  }
}
