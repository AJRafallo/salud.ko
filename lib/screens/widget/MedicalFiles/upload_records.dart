import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_records_ui.dart';

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

  // Pick document
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
      UploadWidgetUI.showSnackBar(context, 'Error picking document.');
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
      UploadWidgetUI.showSnackBar(context, 'Error picking media.');
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
      UploadWidgetUI.showSnackBar(context, 'Error taking photo.');
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
      UploadWidgetUI.showSnackBar(context, 'Error scanning document.');
    }
  }

  // Delete the selected file
  Future<void> _deleteFile() async {
    if (selectedFile != null) {
      String fileName = selectedFile!.path.split('/').last;
      UploadWidgetUI.showDeleteDialog(
        context: context,
        fileName: fileName,
        onConfirmDelete: () {
          setState(() {
            selectedFile = null;
            displayText = "Got Medical Records?\nUpload them Here";
          });
          UploadWidgetUI.showSnackBar(
              context, 'File "$fileName" deleted successfully.');
        },
      );
    } else {
      UploadWidgetUI.showSnackBar(context, 'No file selected to delete.');
    }
  }

  // Upload file to Firebase
  Future<void> _uploadFileToFirebase(String folderId, String folderName) async {
    if (selectedFile == null) return;

    try {
      setState(() {
        isUploading = true;
      });

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = selectedFile!.path.split('/').last;

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/$userId/$folderName/$timestamp-$fileName');
      await storageRef.putFile(selectedFile!);

      final downloadUrl = await storageRef.getDownloadURL();

      // Save file metadata to the all_files collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('all_files')
          .add({
        'name': fileName,
        'filePath': downloadUrl,
        'uploadedAt': Timestamp.now(),
        'folderId': folderId,
      });

      UploadWidgetUI.showSnackBar(
          context, 'File uploaded to "$folderName" successfully!');
      setState(() {
        selectedFile = null;
        displayText = "Got Medical Records?\nUpload them Here";
        isUploading = false;
      });
    } catch (e) {
      print("Error uploading file: $e");
      UploadWidgetUI.showSnackBar(context, 'Failed to upload file.');
      setState(() {
        isUploading = false;
      });
    }
  }

  // Show folder selection dialog
  Future<void> _showFolderSelectionDialog() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final foldersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .get();

    final folders = foldersSnapshot.docs
        .where((doc) => doc['name'] != 'All Files') // Exclude "All Files"
        .toList();

    if (folders.isEmpty) {
      UploadWidgetUI.showSnackBar(context, 'No folders available.');
      return;
    }

    UploadWidgetUI.showFolderSelectionDialog(
      context: context,
      folders: folders,
      onFolderSelected: (folderId, folderName) {
        _uploadFileToFirebase(folderId, folderName);
      },
    );
  }

  // Show upload options
  void _showUploadOptions() {
    UploadWidgetUI.showUploadOptionsDialog(
      context: context,
      onPickMedia: () => _pickMedia(ImageSource.gallery),
      onPickDocument: _pickDocument,
      onTakePhoto: _takePhoto,
      onScanDocument: _scanDocument,
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
      onFileMenuSelected: (String choice) {},
    );
  }
}
