import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'ocr_handler.dart';
import 'upload_records_ui.dart';
import 'scan_dialog.dart';

class UploadWidget extends StatefulWidget {
  final VoidCallback onStartUpload;
  final VoidCallback onEndUpload;

  const UploadWidget({
    super.key,
    required this.onStartUpload,
    required this.onEndUpload,
  });

  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  File? selectedFile;
  String? displayText = "Got Medical Records?\nUpload them Here";
  double uploadProgress = 0.0;

  final ImagePicker _picker = ImagePicker();

  // Pick document (pdf, doc, txt, etc.)
  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
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

  // Pick media (photo/video) from gallery
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

  // Take a photo with camera
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

  // “Scan a Document”
  Future<void> _scanDocument() async {
    ScanMethodDialog.show(
      context: context,
      onCamera: _scanDocumentFromCamera,
      onGallery: _scanDocumentFromGallery,
    );
  }

  // Actual scanning from camera
  Future<void> _scanDocumentFromCamera() async {
    try {
      final XFile? scannedDoc =
          await _picker.pickImage(source: ImageSource.camera);
      if (scannedDoc == null) {
        print("No image selected from camera for OCR.");
        return;
      }
      final File imageFile = File(scannedDoc.path);
      widget.onStartUpload();

      // Extract text using new ML Kit
      final extractedText = await OCRHandler.extractText(imageFile);

      // Save the extracted text to a file
      final dir = await getApplicationDocumentsDirectory();
      final textFile = File('${dir.path}/scanned_text.txt');
      await textFile.writeAsString(extractedText);

      setState(() {
        selectedFile = textFile;
        displayText = "Scanned & Extracted (Camera)";
      });

      print("OCR text saved to: ${textFile.path}");
      UploadWidgetUI.showSnackBar(context, 'Text extracted successfully!');
    } catch (e, stacktrace) {
      print("Error scanning from camera: $e");
      print("Stacktrace: $stacktrace");
      UploadWidgetUI.showSnackBar(context, 'Error extracting text (camera).');
    } finally {
      widget.onEndUpload();
    }
  }

  // Actual scanning from gallery
  Future<void> _scanDocumentFromGallery() async {
    try {
      final XFile? galleryDoc =
          await _picker.pickImage(source: ImageSource.gallery);
      if (galleryDoc == null) {
        print("No image selected from gallery for OCR.");
        return;
      }
      final File imageFile = File(galleryDoc.path);
      widget.onStartUpload();

      // Extract text
      final extractedText = await OCRHandler.extractText(imageFile);

      // Save to .txt
      final dir = await getApplicationDocumentsDirectory();
      final textFile = File('${dir.path}/scanned_text.txt');
      await textFile.writeAsString(extractedText);

      setState(() {
        selectedFile = textFile;
        displayText = "Scanned & Extracted (Gallery)";
      });

      print("OCR text saved to: ${textFile.path}");
      UploadWidgetUI.showSnackBar(context, 'Text extracted successfully!');
    } catch (e, stacktrace) {
      print("Error scanning from gallery: $e");
      print("Stacktrace: $stacktrace");
      UploadWidgetUI.showSnackBar(context, 'Error extracting text (gallery).');
    } finally {
      widget.onEndUpload();
    }
  }

  // Delete the selected file
  Future<void> _deleteFile() async {
    if (selectedFile == null) {
      UploadWidgetUI.showSnackBar(context, 'No file selected to delete.');
      return;
    }
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
  }

  // Upload to Firebase with progress
  Future<void> _uploadFileToFirebase(String folderId, String folderName) async {
    if (selectedFile == null) return;
    try {
      widget.onStartUpload();
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = selectedFile!.path.split('/').last;

      // Firebase Storage ref
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/$userId/$folderName/$timestamp-$fileName');

      // Start upload
      UploadTask uploadTask = storageRef.putFile(selectedFile!);

      // Track progress
      uploadTask.snapshotEvents.listen((snapshot) {
        double progress =
            snapshot.bytesTransferred / snapshot.totalBytes.toDouble();
        setState(() {
          uploadProgress = progress;
        });
      });

      // Wait for completion
      await uploadTask;

      final downloadUrl = await storageRef.getDownloadURL();

      // Save metadata to Firestore
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
        uploadProgress = 0.0;
      });
    } catch (e) {
      print("Error uploading file: $e");
      UploadWidgetUI.showSnackBar(context, 'Failed to upload file.');
      setState(() {
        uploadProgress = 0.0;
      });
    } finally {
      widget.onEndUpload();
    }
  }

  // Show the main upload options
  void _showUploadOptions() {
    UploadWidgetUI.showUploadOptionsDialog(
      context: context,
      onPickMedia: () => _pickMedia(ImageSource.gallery),
      onPickDocument: _pickDocument,
      onTakePhoto: _takePhoto,
      onScanDocument: _scanDocument, // show the subdialog for camera/gallery
    );
  }

  // Show folder selection bottom sheet for final upload
  Future<void> _showFolderSelectionDialog() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final foldersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .get();

    // Exclude "All Files"
    final folders = foldersSnapshot.docs
        .where((doc) =>
            doc['name'] != 'All Files' && doc['name'] != 'Uncategorized')
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
