import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (cameras.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No camera found!')));
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras)));
            }
          },
          child: const Text('Open Camera'),
        ),
      ),
    );
  }
}
