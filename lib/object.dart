import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  String? detectedLabels;
  bool isLoading = true;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      initializeCamera();
    });
  }

  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      setState(() {
        isCameraInitialized = true;
        isLoading = false;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> captureAndLabelImage() async {
    if (!_controller!.value.isInitialized) {
      print('Camera not initialized');
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

      setState(() {
        detectedLabels = labels.map((label) => '${label.label} (${label.confidence.toStringAsFixed(2)})').join(', ');
      });

      await flutterTts.speak(detectedLabels!);

      await imageLabeler.close();
    } catch (e) {
      print('Error capturing and labeling image: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeling App'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isCameraInitialized
              ? Column(
                  children: [
                    Expanded(
                      child: CameraPreview(_controller!),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: captureAndLabelImage,
                        child: Text('Capture and Label Image'),
                      ),
                    ),
                    if (detectedLabels != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Detected Labels: $detectedLabels',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                )
              : Center(child: Text('Failed to initialize camera')),
    );
  }
}
