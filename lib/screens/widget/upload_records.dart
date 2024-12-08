import 'package:flutter/material.dart';
import 'dart:io'; // file handling
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class UploadWidget extends StatefulWidget {
  const UploadWidget({super.key});

  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  File? selectedFile;
  String displayText = "Got Medical Records? Upload them Here";
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
          displayText = result.files.single.name;
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
          displayText = media.name;
        });
      }
    } catch (e) {
      print("Error picking media: $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          selectedFile = File(photo.path);
          displayText = "Photo Captured";
        });
      }
    } catch (e) {
      print("Error taking photo: $e");
    }
  }

  Future<void> _scanDocument() async {
    try {
      final XFile? scannedDoc =
          await _picker.pickImage(source: ImageSource.camera);

      if (scannedDoc != null) {
        setState(() {
          selectedFile = File(scannedDoc.path);
          displayText = "Document Scanned";
        });
      }
    } catch (e) {
      print("Error scanning document: $e");
    }
  }

  Future<void> _deleteFile() async {
    // Prompt the user for confirmation
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete File"),
          content: const Text("Are you sure you want to delete this file?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDB0000)),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        selectedFile = null;
        displayText = "Got Medical Records? Upload them Here";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen width to make it responsive
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: const Color(0xFFD1DBE1),
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                // "X" delete button (only visible if a file is selected)
                if (selectedFile != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: const Color(0xFFDB0000),
                    onPressed: _deleteFile,
                  ),
                Expanded(
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Upload options
              showDialog(
                context: context,
                builder: (context) => _buildCenteredPopup(),
              );
            },
            icon: const Icon(Icons.upload, color: Colors.white, size: 16.0),
            label: const Text(
              "Add",
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2555FF),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredPopup() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Upload Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Browse Photos/Videos'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_copy),
                  title: const Text('Browse Documents'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.scanner),
                  title: const Text('Scan a Document'),
                  onTap: () {
                    Navigator.pop(context);
                    _scanDocument();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
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
  }
}
