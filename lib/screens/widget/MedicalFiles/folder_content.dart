import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saludko/screens/widget/MedicalFiles/upload_records_ui.dart';
// import 'package:rxdart/rxdart.dart';

class FolderContentPage extends StatelessWidget {
  final String folderName;
  final bool isDeletable;
  final String? folderId; // folderId is nullable: null if "All Files"

  const FolderContentPage({
    super.key,
    required this.folderName,
    required this.isDeletable,
    this.folderId,
  });

  User get currentUser => FirebaseAuth.instance.currentUser!;
  bool get isAllFiles => folderName == "All Files";

  @override
  Widget build(BuildContext context) {
    final userId = currentUser.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: isAllFiles
          ? _buildAllFilesView(userId)
          : _buildFolderFilesView(userId, folderId!),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        if (isDeletable && !isAllFiles)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditFolderDialog(context);
              } else if (value == 'delete') {
                _showDeleteFolderDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
      ],
    );
  }

  Widget _buildAllFilesView(String userId) {
    final allFilesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('all_files')
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: allFilesStream,
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
            final fileData = file.data() as Map<String, dynamic>;
            final fileName = fileData['name'] ?? 'Unnamed File';
            return ListTile(
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                fileData['uploadedAt'].toDate().toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              leading: const Icon(Icons.file_present, color: Colors.black),
              onTap: () => _openFile(context, fileData),
              trailing: IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.black),
                onPressed: () {
                  _showFileActionsBottomSheet(context, fileData);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFolderFilesView(String userId, String folderId) {
    final folderFilesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('all_files')
        .where('folderId', isEqualTo: folderId)
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: folderFilesStream,
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
            final fileData = file.data() as Map<String, dynamic>;
            final fileName = fileData['name'] ?? 'Unnamed File';
            return ListTile(
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(fileData['uploadedAt'].toDate().toString()),
              leading: const Icon(Icons.file_present, color: Colors.black),
              onTap: () => _openFile(context, fileData),
              trailing: IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.black),
                onPressed: () {
                  _showFileActionsBottomSheet(context, fileData);
                },
              ),
            );
          },
        );
      },
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      BuildContext context, Map<String, dynamic> fileData) {
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
                children: [
                  Icon(fileIcon, color: Colors.black),
                  const SizedBox(width: 10),
                  Expanded(
                    // Ensures the text does not overflow
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Add ellipsis
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
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
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text('Rename',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, fileData);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.folder_open, color: Colors.black),
              title: const Text('Move',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _moveFile(context, fileData);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.delete, color: Colors.black),
              title: const Text('Delete',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteFileDialog(context, fileData);
              },
            ),
            const SizedBox(height: 10),
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

  void _showRenameDialog(BuildContext context, Map<String, dynamic> fileData) {
    final oldName = fileData['name'] as String? ?? 'Unnamed';
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Center(
            child: Text("Rename File",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      await _renameFile(fileData, newName);
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

  Future<void> _renameFile(
      Map<String, dynamic> fileData, String newName) async {
    final userId = currentUser.uid;
    final fId = fileData['folderId'] as String?;
    final filePath = fileData['filePath'];

    if (fId == null) {
      // Handle files without a folder (Uncategorized)
      final fileDoc = await _getFileDocByPath(userId, null, filePath);
      if (fileDoc != null) {
        await fileDoc.reference.update({'name': newName});
      }
    } else {
      // Update in all_files collection
      final fileDoc = await _getFileDocByPath(userId, fId, filePath);
      if (fileDoc != null) {
        await fileDoc.reference.update({'name': newName});
      }
    }
  }

  void _moveFile(BuildContext context, Map<String, dynamic> fileData) async {
    final userId = currentUser.uid;
    final foldersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .get();

    final otherFolders = foldersSnapshot.docs.toList();

    if (otherFolders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other folders available.')));
      return;
    }

    UploadWidgetUI.showFolderSelectionDialog(
      context: context,
      folders: otherFolders,
      onFolderSelected: (folderId, folderName) async {
        await _moveFileToFolder(fileData, folderId);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _moveFileToFolder(
      Map<String, dynamic> fileData, String targetFolderId) async {
    final userId = currentUser.uid;
    final filePath = fileData['filePath'];
    final oldFolderId = fileData['folderId'];

    // Update the folderId field in 'all_files' collection
    final fileDoc = await _getFileDocByPath(userId, oldFolderId, filePath);
    if (fileDoc != null) {
      await fileDoc.reference.update({'folderId': targetFolderId});
    }
  }

  void _showDeleteFileDialog(
      BuildContext context, Map<String, dynamic> fileData) {
    final fileName = fileData['name'] as String? ?? 'Unnamed File';
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
                      horizontal: 30,
                      vertical: 10,
                    ),
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
                    await _deleteFile(fileData);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB0000),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 10,
                    ),
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

  Future<void> _deleteFile(Map<String, dynamic> fileData) async {
    final userId = currentUser.uid;
    final filePath = fileData['filePath'];
    final fId = fileData['folderId'];

    final fileDoc = await _getFileDocByPath(userId, fId, filePath);
    if (fileDoc != null) {
      await fileDoc.reference.delete();
    }
  }

  Future<DocumentSnapshot?> _getFileDocByPath(
      String userId, String? folderId, String filePath) async {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('all_files')
        .where('filePath', isEqualTo: filePath);

    if (folderId != null) {
      query = query.where('folderId', isEqualTo: folderId);
    } else {
      query = query.where('folderId', isEqualTo: null);
    }

    final snap = await query.limit(1).get();

    if (snap.docs.isNotEmpty) {
      return snap.docs.first;
    }
    return null;
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
                      horizontal: 20,
                      vertical: 10,
                    ),
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
                    if (folderId != null) {
                      final userId = currentUser.uid;
                      final batch = FirebaseFirestore.instance.batch();

                      // Find all files in this folder and set their folderId to null
                      final filesSnapshot = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('all_files')
                          .where('folderId', isEqualTo: folderId)
                          .get();

                      for (var fileDoc in filesSnapshot.docs) {
                        batch.update(fileDoc.reference, {'folderId': null});
                      }

                      // Delete the folder
                      batch.delete(FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('folders')
                          .doc(folderId!));

                      await batch.commit();

                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // go back
                    }
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
                      if (newName.isNotEmpty && folderId != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .collection('folders')
                            .doc(folderId!)
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
