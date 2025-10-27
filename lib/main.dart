import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pwacam/autofill_screen.dart';
import 'biometric.dart';
import 'camera_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    print('debuging ...');
    print('1');
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(
          children: [
            Container(height: 100, width: 300, child: Center(child: Text('data'))),
            ElevatedButton(
              onPressed: () {
                if (cameras.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No camera found!')));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras)));
                }
              },
              child: const Text('Open Camera'),
            ),
            SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AuthScreen()));
              },
              child: const Text('Open Biometric'),
            ),
            SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text('Open Fill'),
            ),
          ],
        ),
      ),
    );
  }
}
