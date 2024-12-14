import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadWidgetUI extends StatelessWidget {
  final bool isFileSelected;
  final String? displayText;
  final VoidCallback onDeleteFile;
  final VoidCallback onUploadOrAddPressed;
  final void Function(String choice) onFileMenuSelected;

  const UploadWidgetUI({
    Key? key,
    required this.isFileSelected,
    required this.displayText,
    required this.onDeleteFile,
    required this.onUploadOrAddPressed,
    required this.onFileMenuSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget textWidget;
    if (!isFileSelected) {
      // No file selected
      // "Got Medical Records?" bold and "Upload them Here" lighter, two lines
      textWidget = Column(
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
              fontWeight: FontWeight.w300, // lighter
              color: Colors.black,
            ),
          ),
        ],
      );
    } else {
      // File selected, show file name truncated
      textWidget = Text(
        displayText ?? '',
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      color: Color(0xFFD1DBE1),
      width: screenWidth,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    icon: Icon(Icons.close),
                    color: Color(0xFFDB0000),
                    onPressed: onDeleteFile,
                    padding: EdgeInsets.all(0),
                    constraints: BoxConstraints(),
                  ),
                Expanded(child: textWidget),
              ],
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onUploadOrAddPressed,
            icon: Icon(Icons.upload, color: Colors.white, size: 16.0),
            label: Text(
              isFileSelected ? "Upload to Folders" : "Add Health Records",
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2555FF),
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Center(
            child: Text(
              "Delete File",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
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
                    side: BorderSide(
                      color: Color(0xFF1A62B7),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF1A62B7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirmDelete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDB0000),
                    padding: EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
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

  static void showFolderSelectionDialog({
    required BuildContext context,
    required List<QueryDocumentSnapshot> folders,
    required void Function(String folderId, String folderName) onFolderSelected,
  }) {
    // Instead of AlertDialog, show a bottom sheet styled similarly to file action popups
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // allow bottom sheet to use available space
      builder: (context) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Icon(Icons.upload, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      "Upload to which folder?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Divider(
                thickness: 0.5,
                color: Colors.black.withOpacity(0.2),
                height: 0,
              ),
              SizedBox(height: 5),
              // Use a ListView to handle variable number of folders and prevent overflow
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 10),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final doc = folders[index];
                    final folderData = doc.data() as Map<String, dynamic>;
                    final folderName =
                        folderData['name'] as String? ?? 'Unnamed';

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      leading: Icon(Icons.folder, color: Color(0xFF1A62B7)),
                      title: Text(
                        folderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onFolderSelected(doc.id, folderName);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Upload Options',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.photo),
                      title: Text('Browse Photos/Videos'),
                      onTap: () {
                        Navigator.pop(context);
                        onPickMedia();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.file_copy),
                      title: Text('Browse Documents'),
                      onTap: () {
                        Navigator.pop(context);
                        onPickDocument();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text('Take a Photo'),
                      onTap: () {
                        Navigator.pop(context);
                        onTakePhoto();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.scanner),
                      title: Text('Scan a Document'),
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
                  child: Icon(
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

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
