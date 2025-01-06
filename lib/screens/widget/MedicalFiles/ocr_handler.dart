import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRHandler {
  /// Extract text from the given [imageFile] using ML Kit's TextRecognizer.
  static Future<String> extractText(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      // Convert the file into an ML Kit input
      final inputImage = InputImage.fromFile(imageFile);

      // Process the image
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Check if anything was recognized
      if (recognizedText.text.trim().isEmpty) {
        throw Exception("No readable text found in the image.");
      }

      return recognizedText.text;
    } finally {
      await textRecognizer.close();
    }
  }
}
