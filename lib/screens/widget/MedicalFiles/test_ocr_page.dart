import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TestOcrPage extends StatefulWidget {
  const TestOcrPage({Key? key}) : super(key: key);

  @override
  State<TestOcrPage> createState() => _TestOcrPageState();
}

class _TestOcrPageState extends State<TestOcrPage> {
  final ImagePicker _picker = ImagePicker();
  String _recognizedText = 'No text recognized yet';

  /// Use the new ML Kit text recognizer
  Future<void> _processImage(File file) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      debugPrint(
          '--- OCR RECOGNIZED TEXT ---\n${recognizedText.text}\n--------------------------');

      // Show on screen
      setState(() {
        if (recognizedText.text.trim().isEmpty) {
          _recognizedText = "No readable text found in the image.";
        } else {
          _recognizedText = recognizedText.text;
        }
      });
    } catch (e, st) {
      debugPrint("OCR Error: $e\n$st");
      setState(() {
        _recognizedText = "Error: $e";
      });
    } finally {
      await textRecognizer.close();
    }
  }

  /// Pick from Gallery
  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return; // user canceled
      await _processImage(File(picked.path));
    } catch (e) {
      debugPrint("Error picking gallery image: $e");
    }
  }

  /// Pick from Camera
  Future<void> _pickFromCamera() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) return; // user canceled
      await _processImage(File(picked.path));
    } catch (e) {
      debugPrint("Error picking camera image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test OCR Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Show recognized text
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
