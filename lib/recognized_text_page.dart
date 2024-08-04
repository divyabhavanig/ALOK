import 'package:flutter/material.dart';

class RecognizedTextPage extends StatelessWidget {
  final String recognizedText;
  final Function(String) onReadAloud;

  RecognizedTextPage({required this.recognizedText, required this.onReadAloud});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recognized Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  recognizedText,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onReadAloud(recognizedText),
              child: Text('Read Aloud'),
            ),
          ],
        ),
      ),
    );
  }
}
