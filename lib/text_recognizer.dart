import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class TextRecognizerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> recognizeText(XFile image) async {
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error recognizing text: $e');
      return 'Error recognizing text';
    }
  }

  Future<String> recognizeTextWeb(Uint8List imageBytes) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        inputImageData: InputImageData(
          size: const Size(100, 100),
          imageRotation: InputImageRotation.rotation0deg,
          inputImageFormat: InputImageFormat.nv21,
          planeData: [
            InputImagePlaneMetadata(
              bytesPerRow: 100,
              height: 100,
              width: 100,
            ),
          ],
        ),
      );
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error recognizing text: $e');
      return 'Error recognizing text';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
