import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadWidgetUI extends StatelessWidget {
  final bool isFileSelected;
  final String? displayText;
  final VoidCallback onDeleteFile;
  final VoidCallback onUploadOrAddPressed;

  const UploadWidgetUI({
    super.key,
    required this.isFileSelected,
    required this.displayText,
    required this.onDeleteFile,
    required this.onUploadOrAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: const Color(0xFFD1DBE1),
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Row(
                children: [
                  if (isFileSelected)
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: const Color(0xFFDB0000),
                      onPressed: onDeleteFile,
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                    ),
                  Expanded(
                    child: Text(
                      displayText ?? "Got Medical Records?\nUpload them Here",
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onUploadOrAddPressed,
            icon: const Icon(Icons.upload, color: Colors.white, size: 16.0),
            label: Text(
              isFileSelected ? "Upload to Folders" : "Add Health Records",
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
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

  // Static helper method to show Delete Confirmation Dialog
  static void showDeleteDialog({
    required BuildContext context,
    required VoidCallback onConfirmDelete,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: const Center(
            child: Text(
              "Delete File",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              Text(
                "Are you sure you want to delete this file?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFF1A62B7),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF1A62B7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirmDelete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB0000),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Static method to show Folder Selection Dialog
  static void showFolderSelectionDialog({
    required BuildContext context,
    required List<QueryDocumentSnapshot> folders,
    required void Function(String folderId, String folderName) onFolderSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload to Folder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: folders.map((doc) {
              final folderData = doc.data() as Map<String, dynamic>;
              final folderName = folderData['name'] as String? ?? 'Unnamed';
              return ListTile(
                title: Text(folderName),
                onTap: () {
                  Navigator.pop(context);
                  onFolderSelected(doc.id, folderName);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Static method to show the Upload Options Dialog
  static void showUploadOptionsDialog({
    required BuildContext context,
    required VoidCallback onPickMedia,
    required VoidCallback onPickDocument,
    required VoidCallback onTakePhoto,
    required VoidCallback onScanDocument,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                      'Upload Options',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.photo),
                      title: const Text('Browse Photos/Videos'),
                      onTap: () {
                        Navigator.pop(context);
                        onPickMedia();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.file_copy),
                      title: const Text('Browse Documents'),
                      onTap: () {
                        Navigator.pop(context);
                        onPickDocument();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take a Photo'),
                      onTap: () {
                        Navigator.pop(context);
                        onTakePhoto();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.scanner),
                      title: const Text('Scan a Document'),
                      onTap: () {
                        Navigator.pop(context);
                        onScanDocument();
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
      },
    );
  }

  // Static method to show a SnackBar
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
