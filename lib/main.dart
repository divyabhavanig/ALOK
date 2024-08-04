import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'text.dart';
import 'object.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALOK',
      theme: ThemeData.dark(), // Use dark theme for accessibility
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakWelcome();
  }

  Future<void> _speakWelcome() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak("Welcome to ALOK. Swipe left for Image Detection, swipe right for Text Recognition.");
  }

  int _currentIndex = 0;

  final List<Widget> _pages = [
    TextRecognitionPage(),
    HomeScreen(),
  ];

  void _navigateLeft() {
    setState(() {
      _currentIndex = 0; // Navigate to Text Recognition
    });
    _speakInstruction("Text Recognition");
  }

  void _navigateRight() {
    setState(() {
      _currentIndex = 1; // Navigate to Object Detection
    });
    _speakInstruction("Image Detection");
  }

  Future<void> _speakInstruction(String action) async {
    await flutterTts.stop();
    await flutterTts.speak("$action selected.");
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx < 0) {
            // Swiped left
            _navigateLeft();
          } else if (details.delta.dx > 0) {
            // Swiped right
            _navigateRight();
          }
        },
        child: _pages[_currentIndex],
      ),
    );
  }
}
