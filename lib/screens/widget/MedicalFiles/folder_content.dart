import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:saludko/screens/widget/MedicalFiles/upload_records_ui.dart';
import 'package:saludko/screens/widget/MedicalFiles/file_viewer.dart';

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
            final uploadedAt = fileData['uploadedAt'] as Timestamp;

            final formattedDate =
                DateFormat('MMMM d, yyyy ─ h:mm a').format(uploadedAt.toDate());

            return ListTile(
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  formattedDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              leading: _getFileIcon(fileName),
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
            final uploadedAt = fileData['uploadedAt'] as Timestamp;

            final formattedDate =
                DateFormat('MMMM d, yyyy ─ h:mm a').format(uploadedAt.toDate());

            return ListTile(
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  formattedDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              leading: _getFileIcon(fileName),
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

  Icon _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    IconData iconData;

    if (['png', 'jpg', 'jpeg', 'gif'].contains(extension)) {
      iconData = Icons.image;
    } else if (['pdf'].contains(extension)) {
      iconData = Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(extension)) {
      iconData = Icons.description;
    } else if (['txt'].contains(extension)) {
      iconData = Icons.text_snippet;
    } else {
      iconData = Icons.insert_drive_file;
    }

    return Icon(iconData, color: Colors.black);
  }

  void _openFile(BuildContext context, Map<String, dynamic> fileData) {
    final filePath = fileData['filePath'] as String?;
    final fileName = fileData['name'] as String? ?? 'Unnamed';

    if (filePath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerPage(
          fileUrl: filePath,
          fileName: fileName,
        ),
      ),
    );
  }

  /// ======================
  ///  Bottom Sheet Actions
  /// ======================
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
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  fileIcon,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            // Rename
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text(
                'Rename',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, fileData);
              },
            ),
            // Move or Copy
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.folder_open, color: Colors.black),
              // If we are in "All Files", label is "Copy"; otherwise, "Move"
              title: Text(
                isAllFiles ? 'Copy' : 'Move',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                // If we are in "All Files", call _copyFile; otherwise, _moveFile
                if (isAllFiles) {
                  _copyFile(context, fileData);
                } else {
                  _moveFile(context, fileData);
                }
              },
            ),
            // Delete
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

  /// ==============
  ///  Rename File
  /// ==============
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
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      try {
                        await _renameFile(fileData, newName);
                      } catch (e) {
                        debugPrint("Error renaming file: $e");
                      }
                      if (context.mounted) Navigator.pop(context);
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
                    "Rename",
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

  Future<void> _renameFile(
      Map<String, dynamic> fileData, String newName) async {
    final userId = currentUser.uid;
    final fId = fileData['folderId'] as String?;
    final filePath = fileData['filePath'];

    try {
      final fileDoc = await _getFileDocByPath(userId, fId, filePath);
      if (fileDoc != null) {
        await fileDoc.reference.update({'name': newName});
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =========================
  ///  Move (for non–All Files)
  /// =========================
  void _moveFile(BuildContext context, Map<String, dynamic> fileData) async {
    final userId = currentUser.uid;

    try {
      final foldersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('folders')
          .get();

      // Exclude "All Files" from moving into itself, if you like.
      final otherFolders = foldersSnapshot.docs
          .where((doc) => doc.data()['name'] != 'All Files')
          .toList();

      if (otherFolders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other folders available.')),
        );
        return;
      }

      UploadWidgetUI.showFolderSelectionDialog(
        context: context,
        folders: otherFolders,
        onFolderSelected: (targetFolderId, folderName) async {
          try {
            await _moveFileToFolder(fileData, targetFolderId);
          } catch (e) {
            debugPrint("Error moving file: $e");
          }
          // Close the folder selection dialog
          if (context.mounted) Navigator.pop(context);
        },
      );
    } catch (e) {
      debugPrint("Error in _moveFile: $e");
    }
  }

  Future<void> _moveFileToFolder(
      Map<String, dynamic> fileData, String targetFolderId) async {
    final userId = currentUser.uid;
    final filePath = fileData['filePath'];
    final oldFolderId = fileData['folderId'];

    try {
      final fileDoc = await _getFileDocByPath(userId, oldFolderId, filePath);
      if (fileDoc != null) {
        await fileDoc.reference.update({'folderId': targetFolderId});
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =======================
  ///  Copy (for All Files)
  /// =======================
  void _copyFile(BuildContext context, Map<String, dynamic> fileData) async {
    final userId = currentUser.uid;

    try {
      final foldersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('folders')
          .get();

      // Optionally exclude "All Files" if you don't want to copy into "All Files".
      final validFolders = foldersSnapshot.docs
          .where((doc) => doc.data()['name'] != 'All Files')
          .toList();

      if (validFolders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other folders available.')),
        );
        return;
      }

      UploadWidgetUI.showFolderSelectionDialog(
        context: context,
        folders: validFolders,
        onFolderSelected: (targetFolderId, folderName) async {
          try {
            await _copyFileToFolder(fileData, targetFolderId);
          } catch (e) {
            debugPrint("Error copying file: $e");
          }
          if (context.mounted) Navigator.pop(context);
        },
      );
    } catch (e) {
      debugPrint("Error in _copyFile: $e");
    }
  }

  Future<void> _copyFileToFolder(
      Map<String, dynamic> fileData, String targetFolderId) async {
    final userId = currentUser.uid;

    try {
      // Add a new doc to 'all_files' duplicating the info
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('all_files')
          .add({
        'name': fileData['name'],
        'filePath': fileData['filePath'],
        'folderId': targetFolderId,
        'uploadedAt': fileData['uploadedAt'] ?? Timestamp.now(),
        // Add any other fields needed for your app
      });
    } catch (e) {
      rethrow;
    }
  }

  /// =============
  ///  Delete File
  /// =============
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
                    try {
                      await _deleteFile(fileData);
                    } catch (e) {
                      debugPrint("Error deleting file: $e");
                    }
                    if (context.mounted) Navigator.pop(context);
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

  Future<void> _deleteFile(Map<String, dynamic> fileData) async {
    final userId = currentUser.uid;
    final filePath = fileData['filePath'];
    final fId = fileData['folderId'];

    try {
      final fileDoc = await _getFileDocByPath(userId, fId, filePath);
      if (fileDoc != null) {
        await fileDoc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ===========================================
  ///  Generic helper to find doc by filePath
  /// ===========================================
  Future<DocumentSnapshot?> _getFileDocByPath(
      String userId, String? folderId, String filePath) async {
    try {
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
    } catch (e) {
      debugPrint("Error in _getFileDocByPath: $e");
      return null;
    }
  }

  /// =============================
  ///  Delete Entire Folder Action
  /// =============================
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
                    if (folderId != null) {
                      try {
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

                        // Delete the folder document
                        batch.delete(FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('folders')
                            .doc(folderId!));

                        await batch.commit();

                        // Pop the "Delete" dialog
                        if (context.mounted) Navigator.pop(context);
                        // Pop the folder content screen
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        debugPrint("Error deleting folder: $e");
                      }
                    }
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

  /// =========================
  ///  Edit Folder (Rename)
  /// =========================
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () async {
                      final newName = folderNameController.text.trim();
                      if (newName.isNotEmpty && folderId != null) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('folders')
                              .doc(folderId!)
                              .update({"name": newName});
                        } catch (e) {
                          debugPrint("Error editing folder name: $e");
                        }
                        if (context.mounted) Navigator.pop(context);
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
