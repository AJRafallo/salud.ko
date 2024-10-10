import 'package:flutter/material.dart';
import 'dart:io'; // file handling
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class UploadWidget extends StatefulWidget {
  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  File? selectedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print("Error picking document: $e"); // Log the error
    }
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? media = await _picker.pickImage(source: source);

      if (media != null) {
        setState(() {
          selectedFile = File(media.path);
        });
      }
    } catch (e) {
      print("Error picking media: $e"); // Log the error
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          selectedFile = File(photo.path);
        });
      }
    } catch (e) {
      print("Error taking photo: $e"); // Log the error
    }
  }

  Future<void> _scanDocument() async {
    try {
      final XFile? scannedDoc =
          await _picker.pickImage(source: ImageSource.camera);

      if (scannedDoc != null) {
        setState(() {
          selectedFile = File(scannedDoc.path);
        });
      }
    } catch (e) {
      print("Error scanning document: $e"); // Log the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 70,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                selectedFile == null
                    ? Text('No file selected.')
                    : Text('Selected: ${selectedFile!.path}'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildUploadOptions(),
                    );
                  },
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload File'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('Browse Photos/Videos'),
            onTap: () {
              Navigator.pop(context);
              _pickMedia(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: Icon(Icons.file_copy),
            title: Text('Browse Documents'),
            onTap: () {
              Navigator.pop(context);
              _pickDocument();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a Photo'),
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
          ListTile(
            leading: Icon(Icons.scanner),
            title: Text('Scan a Document'),
            onTap: () {
              Navigator.pop(context);
              _scanDocument();
            },
          ),
        ],
      ),
    );
  }
}
