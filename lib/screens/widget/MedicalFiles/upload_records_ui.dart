import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadWidgetUI extends StatelessWidget {
  final bool isFileSelected;
  final String? displayText;
  final VoidCallback onDeleteFile;
  final VoidCallback onUploadOrAddPressed;
  final void Function(String choice) onFileMenuSelected;

  const UploadWidgetUI({
    super.key,
    required this.isFileSelected,
    required this.displayText,
    required this.onDeleteFile,
    required this.onUploadOrAddPressed,
    required this.onFileMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget textWidget;
    if (!isFileSelected) {
      textWidget = const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Got Medical Records?",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Upload them Here",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
        ],
      );
    } else {
      // If a file is selected
      textWidget = Text(
        displayText ?? '',
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

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
            child: Row(
              children: [
                if (isFileSelected)
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: const Color(0xFFDB0000),
                    onPressed: onDeleteFile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                Expanded(child: textWidget),
              ],
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

  // Show the delete confirmation dialog
  static void showDeleteDialog({
    required BuildContext context,
    required String fileName,
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              const Text(
                "Are you sure you want to delete this file?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Text(
                "$fileName will be deleted forever.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
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
                    side: const BorderSide(color: Color(0xFF1A62B7)),
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

  // Show folder selection bottom sheet
  static Future<void> showFolderSelectionDialog({
    required BuildContext context,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> folders,
    required void Function(String folderId, String folderName) onFolderSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Icon(Icons.upload, color: Colors.black),
                    const SizedBox(width: 10),
                    const Text(
                      "Upload to which folder?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                thickness: 0.5,
                color: Colors.black.withOpacity(0.2),
                height: 0,
              ),
              const SizedBox(height: 5),
              // Folders list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final doc = folders[index];
                    final folderData = doc.data();
                    final folderName =
                        folderData['name'] as String? ?? 'Unnamed';

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      leading:
                          const Icon(Icons.folder, color: Color(0xFF1A62B7)),
                      title: Text(
                        folderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        onFolderSelected(doc.id, folderName);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Show the upload options dialog
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

  // Helper to show a SnackBar
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
