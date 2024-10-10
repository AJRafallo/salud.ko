import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/UploadRecords.dart';

class MedicalFilesPage extends StatelessWidget {
  const MedicalFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: const Text('Medical Files Content'),
            ),
          ),
          // Directly include the UploadWidget at the bottom
          Expanded(
            child: UploadWidget(), // Show UploadWidget directly
          ),
        ],
      ),
    );
  }
}
