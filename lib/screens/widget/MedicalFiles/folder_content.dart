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

  User get currentUser => FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          folderName,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          if (isDeletable)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
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
                leading: const Icon(Icons.file_present, color: Colors.black),
                onTap: () =>
                    _openFile(context, file.data() as Map<String, dynamic>),
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: () => _showFileActionsBottomSheet(context, file),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openFile(BuildContext context, Map<String, dynamic> fileData) {
    final filePath = fileData['filePath'] as String?;
    final fileName = fileData['name'] as String? ?? 'Unnamed';

    if (filePath == null) return;

    final extension = fileName.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'gif'].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: Text(
                fileName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            body: Center(
              child: Image.network(filePath),
            ),
          ),
        ),
      );
    } else {
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

  void _showFileActionsBottomSheet(
      BuildContext context, QueryDocumentSnapshot file) {
    final fileData = file.data() as Map<String, dynamic>;
    final fileName = fileData['name'] as String? ?? 'Unnamed';
    final fileIcon = _getFileIcon(fileName);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(fileIcon, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 0.5, color: Colors.black54, height: 0),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text('Rename',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, file.id, fileName);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.folder_open, color: Colors.black),
              title: const Text('Move',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _moveFile(context, file.id, fileData, fileName);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.delete, color: Colors.black),
              title: const Text('Delete',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteFileDialog(context, file.id, fileName);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'gif'].contains(extension)) {
      return Icons.image;
    } else {
      return Icons.insert_drive_file;
    }
  }

  void _showRenameDialog(BuildContext context, String fileId, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Center(
            child: Text(
              "Rename File",
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
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "New Name",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF1A62B7)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        color: Color(0xFF1A62B7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      await _renameFile(fileId, newName);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A62B7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Rename",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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

  void _moveFile(BuildContext context, String fileId,
      Map<String, dynamic> fileData, String fileName) async {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectFolderDestinationPage(
          folders: otherFolders,
          onFolderSelected: (targetFolderId) async {
            await _moveFileToFolder(fileId, fileData, targetFolderId);
            Navigator.pop(context); // Go back after moving the file
          },
        ),
      ),
    );
  }

  Future<void> _moveFileToFolder(String fileId, Map<String, dynamic> fileData,
      String targetFolderId) async {
    final userId = currentUser.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .doc(targetFolderId)
        .collection('files')
        .add(fileData);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .doc(folderId)
        .collection('files')
        .doc(fileId)
        .delete();
  }

  void _showDeleteFileDialog(
      BuildContext context, String fileId, String fileName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        color: Color(0xFF1A62B7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
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
                        .collection('files')
                        .doc(fileId)
                        .delete();

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB0000),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
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
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    side: const BorderSide(color: Color(0xFF1A62B7)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        color: Color(0xFF1A62B7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
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
                        horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
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
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          actionsPadding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
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
                      side: const BorderSide(color: Color(0xFF1A62B7)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          color: Color(0xFF1A62B7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
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
                          horizontal: 25, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
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

// Select Folder Destination
class SelectFolderDestinationPage extends StatelessWidget {
  final List<QueryDocumentSnapshot> folders;
  final Future<void> Function(String folderId) onFolderSelected;

  const SelectFolderDestinationPage({
    super.key,
    required this.folders,
    required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.close, color: Colors.black),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          "Select Folder Destination",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 10),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                final folderData = folder.data() as Map<String, dynamic>;
                final folderName = folderData['name'] as String? ?? 'Unnamed';

                return ListTile(
                  title: Text(folderName),
                  leading: const Icon(Icons.folder, color: Color(0xFF1A62B7)),
                  onTap: () async {
                    await onFolderSelected(folder.id);
                  },
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 15),
            ),
          ),
        ],
      ),
    );
  }
}
