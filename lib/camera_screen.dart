import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // اضافه کردن این import
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;
  VideoPlayerController? _videoPlayerController;

  bool _isRecording = false;
  bool _showPreview = false;
  XFile? _videoFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _cameraController = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeCameraControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_cameraController.value.isInitialized || _showPreview) {
      return;
    }

    if (_isRecording) {
      try {
        _videoFile = await _cameraController.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _showPreview = true;
        });

        // ----- شروع تغییرات اصلی برای پشتیبانی از وب -----
        if (kIsWeb) {
          // اگر پلتفرم وب بود از networkUrl استفاده کن
          _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(_videoFile!.path));
        } else {
          // در غیر این صورت (موبایل) از file استفاده کن
          _videoPlayerController = VideoPlayerController.file(File(_videoFile!.path));
        }
        // ----- پایان تغییرات اصلی -----

        await _videoPlayerController?.initialize().then((_) {
          setState(() {});
          _videoPlayerController?.play();
          _videoPlayerController?.setLooping(true);
        });
      } catch (e) {
        print(e);
      }
    } else {
      try {
        await _cameraController.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _simulateUpload() async {
    if (_videoFile == null) return;

    final Uint8List videoBytes = await _videoFile!.readAsBytes();
    print('Simulating upload...');
    print('Video byte length: ${videoBytes.lengthInBytes}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload simulation successful!')));
      Navigator.of(context).pop();
    }
  }

  void _discardVideo() {
    setState(() {
      _showPreview = false;
      _videoFile = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showPreview ? 'Video Preview' : 'Record Video'),
        actions: [if (_showPreview) IconButton(icon: const Icon(Icons.close), onPressed: _discardVideo, tooltip: 'Record Again')],
      ),
      body: FutureBuilder<void>(
        future: _initializeCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _showPreview ? _buildPreviewWidget() : _buildCameraWidget();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildCameraWidget() {
    return Stack(
      children: [
        SizedBox.expand(child: CameraPreview(_cameraController)),
        Positioned(
          bottom: 30.0,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: _toggleRecording,
              child: Icon(_isRecording ? Icons.stop : Icons.videocam, color: Colors.white),
              backgroundColor: _isRecording ? Colors.red : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
          Expanded(
            child: AspectRatio(aspectRatio: _videoPlayerController!.value.aspectRatio, child: VideoPlayer(_videoPlayerController!)),
          )
        else
          const Expanded(child: Center(child: CircularProgressIndicator())),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _discardVideo,
              icon: const Icon(Icons.replay),
              label: const Text('Record Again'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            ElevatedButton.icon(
              onPressed: _simulateUpload,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
