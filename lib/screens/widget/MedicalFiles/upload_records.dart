import 'package:flutter/material.dart';
import 'dart:io'; // File handling
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/MedicalFiles/upload_records_ui.dart';

class UploadWidget extends StatefulWidget {
  const UploadWidget({super.key});

  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  File? selectedFile;
  String? displayText = "Got Medical Records?\nUpload them Here";
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  // Pick a document
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
      print("Error picking document: $e");
    }
  }

  // Pick media
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

  // Capture photo
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

  // Scan document
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

  // Delete the selected file
  Future<void> _deleteFile() async {
    UploadWidgetUI.showDeleteDialog(
      context: context,
      onConfirmDelete: () {
        setState(() {
          selectedFile = null;
          displayText = "Got Medical Records?\nUpload them Here";
        });
      },
    );
  }

  // Upload file to Firebase
  Future<void> _uploadFileToFirebase(String folderId, String folderName) async {
    if (selectedFile == null) return;

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = selectedFile!.path.split('/').last;

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/$userId/$folderName/$timestamp-$fileName');
      await storageRef.putFile(selectedFile!);

      final downloadUrl = await storageRef.getDownloadURL();

      // Save file metadata to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('folders')
          .doc(folderId)
          .collection('files')
          .add({
        'name': fileName,
        'filePath': downloadUrl,
        'uploadedAt': Timestamp.now(),
      });

      // Upload to "All Files"
      final allFilesFolder = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('folders')
          .doc('all_files');
      await allFilesFolder.collection('files').add({
        'name': fileName,
        'filePath': downloadUrl,
        'uploadedAt': Timestamp.now(),
      });

      UploadWidgetUI.showSnackBar(
          context, 'File uploaded to "$folderName" successfully!');
      setState(() {
        selectedFile = null;
        displayText = "Got Medical Records?\nUpload them Here";
      });
    } catch (e) {
      print("Error uploading file: $e");
      UploadWidgetUI.showSnackBar(context, 'Failed to upload file.');
    }
  }

  // Show folder selection dialog (for moving the file)
  Future<void> _showFolderSelectionDialog() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final foldersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .get();

    if (foldersSnapshot.docs.isEmpty) {
      UploadWidgetUI.showSnackBar(context, 'No folders available.');
      return;
    }

    final otherFolders = foldersSnapshot.docs
        .where((doc) => doc.data()['name'] != "All Files")
        .toList();

    UploadWidgetUI.showFolderSelectionDialog(
      context: context,
      folders: otherFolders,
      onFolderSelected: (folderId, folderName) {
        _uploadFileToFirebase(folderId, folderName);
      },
    );
  }

  // Show upload options dialog
  void _showUploadOptions() {
    UploadWidgetUI.showUploadOptionsDialog(
      context: context,
      onPickMedia: () => _pickMedia(ImageSource.gallery),
      onPickDocument: _pickDocument,
      onTakePhoto: _takePhoto,
      onScanDocument: _scanDocument,
    );
  }

  // When a menu action (Rename, Move, Delete) is selected
  void _onFileMenuSelected(String choice) {
    switch (choice) {
      case 'rename':
        _showRenameDialog();
        break;
      case 'move':
        _showFolderSelectionDialog();
        break;
      case 'delete':
        _deleteFile();
        break;
    }
  }

  // Show dialog to rename the file
  void _showRenameDialog() {
    final controller = TextEditingController(text: displayText);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    displayText = newName;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Rename"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return UploadWidgetUI(
      isFileSelected: selectedFile != null,
      displayText: displayText,
      onDeleteFile: _deleteFile,
      onUploadOrAddPressed: selectedFile == null
          ? _showUploadOptions
          : _showFolderSelectionDialog,
      onFileMenuSelected: _onFileMenuSelected,
    );
  }
}
