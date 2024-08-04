import 'dart:io';
import 'dart:typed_data';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'text_recognizer.dart';
import 'recognized_text_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Recognition App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TextRecognitionPage(),
    );
  }
}

class TextRecognitionPage extends StatefulWidget {
  @override
  _TextRecognitionPageState createState() => _TextRecognitionPageState();
}

class _TextRecognitionPageState extends State<TextRecognitionPage> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizerService _textRecognizerService = TextRecognizerService();
  final FlutterTts _flutterTts = FlutterTts();
  XFile? _image;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      if (kIsWeb) {
        _imageBytes = await pickedImage.readAsBytes();
        await _recognizeTextWeb(_imageBytes!);
      } else {
        await _recognizeText(pickedImage);
      }
    } else {
      debugPrint('No image selected.');
    }
  }

  Future<void> _captureImage() async {
    final capturedImage = await _picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        _image = capturedImage;
      });
      await _recognizeText(capturedImage);
    } else {
      debugPrint('No image captured.');
    }
  }

  Future<void> _recognizeText(XFile image) async {
    final recognizedText = await _textRecognizerService.recognizeText(image);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecognizedTextPage(
          recognizedText: recognizedText,
          onReadAloud: _readAloud,
        ),
      ),
    );
  }

  Future<void> _recognizeTextWeb(Uint8List imageBytes) async {
    final recognizedText = await _textRecognizerService.recognizeTextWeb(imageBytes);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecognizedTextPage(
          recognizedText: recognizedText,
          onReadAloud: _readAloud,
        ),
      ),
    );
  }

  Future<void> _readAloud(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _textRecognizerService.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Recognition'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                kIsWeb
                    ? _imageBytes != null
                        ? Image.memory(_imageBytes!)
                        : Container()
                    : Image.file(File(_image!.path)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: _captureImage,
                child: Text('Capture Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
