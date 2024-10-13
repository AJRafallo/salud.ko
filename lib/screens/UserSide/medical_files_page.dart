import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/UploadRecords.dart';

class MedicalFilesPage extends StatelessWidget {
  const MedicalFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Medical Files Content'),
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
