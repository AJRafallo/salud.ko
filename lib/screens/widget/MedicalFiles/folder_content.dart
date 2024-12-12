import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class FolderContentPage extends StatelessWidget {
  final String folderName;
  final bool isDeletable;
  final String folderId;

  const FolderContentPage({
    super.key,
    required this.folderName,
    required this.isDeletable,
    required this.folderId,
  });

  // Get current user (non-null because the user must be logged in)
  User get currentUser => FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
        actions: [
          if (isDeletable)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditFolderDialog(context);
                } else if (value == 'delete') {
                  _showDeleteFolderDialog(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('folders')
            .doc(folderId)
            .collection('files')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final files = snapshot.data?.docs ?? [];

          if (files.isEmpty) {
            return const Center(
              child: Text(
                "This folder is empty.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            );
          }

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final fileName = file['name'] ?? 'Unnamed File';

              return ListTile(
                title: Text(fileName),
                subtitle: Text(file['uploadedAt'].toDate().toString()),
                leading: const Icon(Icons.file_present),
                onTap: () =>
                    _openFile(context, file.data() as Map<String, dynamic>),
                trailing: PopupMenuButton<String>(
                  onSelected: (choice) =>
                      _onFileMenuSelected(context, file, choice),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Text('Rename'),
                    ),
                    const PopupMenuItem(
                      value: 'move',
                      child: Text('Move'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Opens the file: if image, show in new screen; else attempt to launch URL
  void _openFile(BuildContext context, Map<String, dynamic> fileData) {
    final filePath = fileData['filePath'] as String?;
    final fileName = fileData['name'] as String? ?? 'Unnamed';

    if (filePath == null) return;

    final extension = fileName.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'gif'].contains(extension)) {
      // Show image in a new page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(fileName)),
            body: Center(
              child: Image.network(filePath),
            ),
          ),
        ),
      );
    } else {
      // Try launching the file in browser or other external application
      _launchURL(context, filePath);
    }
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open file.')));
    }
  }

  void _onFileMenuSelected(
      BuildContext context, QueryDocumentSnapshot file, String choice) {
    final fileId = file.id;
    final fileData = file.data() as Map<String, dynamic>;
    final fileName = fileData['name'] as String? ?? 'Unnamed';

    switch (choice) {
      case 'rename':
        _showRenameDialog(context, fileId, fileName);
        break;
      case 'move':
        _moveFile(context, fileId, fileData);
        break;
      case 'delete':
        _deleteFile(context, fileId);
        break;
    }
  }

  // Show dialog to rename the file
  void _showRenameDialog(BuildContext context, String fileId, String oldName) {
    final controller = TextEditingController(text: oldName);
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
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await _renameFile(fileId, newName);
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

  Future<void> _renameFile(String fileId, String newName) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('folders')
        .doc(folderId)
        .collection('files')
        .doc(fileId)
        .update({'name': newName});
  }

  // Move file to another folder
  Future<void> _moveFile(BuildContext context, String fileId,
      Map<String, dynamic> fileData) async {
    final userId = currentUser.uid;
    final foldersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .get();

    final otherFolders = foldersSnapshot.docs
        .where((doc) => doc.data()['name'] != "All Files" && doc.id != folderId)
        .toList();

    if (otherFolders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other folders available.')));
      return;
    }

    // Show dialog to select folder
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Move File to Folder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: otherFolders.map((doc) {
              final folderData = doc.data();
              final targetFolderName =
                  folderData['name'] as String? ?? 'Unnamed';
              return ListTile(
                title: Text(targetFolderName),
                onTap: () async {
                  Navigator.pop(context);
                  await _moveFileToFolder(fileId, fileData, doc.id);
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

  Future<void> _moveFileToFolder(String fileId, Map<String, dynamic> fileData,
      String targetFolderId) async {
    final userId = currentUser.uid;
    // Add file to the target folder
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .doc(targetFolderId)
        .collection('files')
        .add(fileData);

    // Delete file from the current folder
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .doc(folderId)
        .collection('files')
        .doc(fileId)
        .delete();
  }

  // Delete file from current folder
  Future<void> _deleteFile(BuildContext context, String fileId) async {
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
                  onPressed: () async {
                    // Delete from Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .collection('folders')
                        .doc(folderId)
                        .collection('files')
                        .doc(fileId)
                        .delete();

                    Navigator.pop(context);
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

  void _showDeleteFolderDialog(BuildContext context) {
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
              "Delete Folder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              Text(
                "Are you sure you want to delete this folder?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                "You can still access your files in the \"All Files\" folder.",
                textAlign: TextAlign.center,
                style: TextStyle(
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
                    side: const BorderSide(
                      color: Color(0xFF1A62B7),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
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
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .collection('folders')
                        .doc(folderId)
                        .delete();

                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB0000),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
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

  void _showEditFolderDialog(BuildContext context) {
    final folderNameController = TextEditingController(text: folderName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Center(
            child: Text(
              "Edit Folder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: folderNameController,
                  decoration: const InputDecoration(
                    hintText: "Folder Name",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 15,
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFF1A62B7),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
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
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () async {
                      final newName = folderNameController.text.trim();
                      if (newName.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .collection('folders')
                            .doc(folderId)
                            .update({"name": newName});

                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A62B7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
