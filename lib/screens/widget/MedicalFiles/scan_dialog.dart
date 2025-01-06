import 'package:flutter/material.dart';

class ScanMethodDialog {
  static void show({
    required BuildContext context,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Scan Document (OCR)',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Scan from Camera'),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        onCamera();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo),
                      title: const Text('Scan from Gallery'),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        onGallery();
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(dialogContext),
                  child: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
