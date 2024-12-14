import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rxdart/rxdart.dart';

class FolderContentPage extends StatelessWidget {
  final String folderName;
  final bool isDeletable;
  final String? folderId; // folderId is nullable: null if "All Files"

  FolderContentPage({
    Key? key,
    required this.folderName,
    required this.isDeletable,
    this.folderId,
  }) : super(key: key);

  User get currentUser => FirebaseAuth.instance.currentUser!;
  bool get isAllFiles => folderName == "All Files";

  @override
  Widget build(BuildContext context) {
    final userId = currentUser.uid;

    if (!isAllFiles) {
      // Normal folder: just show that folder's files
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: _buildFolderFilesStream(userId, folderId!),
      );
    } else {
      // "All Files": we must combine all folder files into one view
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('folders')
              .get(),
          builder: (context, folderSnapshot) {
            if (folderSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (folderSnapshot.hasError) {
              return Center(child: Text("Error: ${folderSnapshot.error}"));
            }
            final folders = folderSnapshot.data?.docs ?? [];
            if (folders.isEmpty) {
              return Center(
                child: Text(
                  "This folder is empty.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              );
            }

            // Build a stream that combines all folders' files
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _combineAllFolderFiles(userId, folders),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final allFiles = snapshot.data ?? [];

                if (allFiles.isEmpty) {
                  return Center(
                    child: Text(
                      "This folder is empty.",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  );
                }

                // Sort by uploadedAt descending
                allFiles.sort((a, b) {
                  final aTime = a['uploadedAt'] as Timestamp;
                  final bTime = b['uploadedAt'] as Timestamp;
                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  itemCount: allFiles.length,
                  itemBuilder: (context, index) {
                    final fileData = allFiles[index];
                    final fileName = fileData['name'] ?? 'Unnamed File';
                    return ListTile(
                      title: Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          Text(fileData['uploadedAt'].toDate().toString()),
                      leading: Icon(Icons.file_present, color: Colors.black),
                      onTap: () => _openFile(context, fileData),
                      trailing: IconButton(
                        icon: Icon(Icons.more_horiz, color: Colors.black),
                        onPressed: () {
                          _showFileActionsBottomSheet(context, fileData);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        folderName,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      actions: [
        if (isDeletable && !isAllFiles)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditFolderDialog(context);
              } else if (value == 'delete') {
                _showDeleteFolderDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
      ],
    );
  }

  Widget _buildFolderFilesStream(String userId, String folderId) {
    final fileStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .doc(folderId)
        .collection('files')
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: fileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final files = snapshot.data?.docs ?? [];
        if (files.isEmpty) {
          return Center(
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
            final fileData = file.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(file['uploadedAt'].toDate().toString()),
              leading: Icon(Icons.file_present, color: Colors.black),
              onTap: () => _openFile(context, fileData),
              trailing: IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.black),
                onPressed: () {
                  // Convert QueryDocumentSnapshot to Map with folderId known
                  fileData['folderId'] = folderId;
                  _showFileActionsBottomSheet(context, fileData);
                },
              ),
            );
          },
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _combineAllFolderFiles(
      String userId, List<DocumentSnapshot> folders) {
    // For each folder, get its files stream
    final folderFileStreams = folders.map((folderDoc) {
      final fid = folderDoc.id;
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('folders')
          .doc(fid)
          .collection('files')
          .snapshots()
          .map((snap) {
        return snap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['folderId'] = fid; // store folderId in data
          return data;
        }).toList();
      });
    }).toList();

    // Combine all folder file lists into one list
    // We'll use combineLatest to combine all folder streams into one
    return Rx.combineLatest<List<Map<String, dynamic>>,
        List<Map<String, dynamic>>>(
      folderFileStreams,
      (lists) {
        // Flatten all lists into one
        return lists.expand((list) => list).toList();
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
                icon: Icon(Icons.chevron_left, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
          .showSnackBar(SnackBar(content: Text('Could not open file.')));
    }
  }

  void _showFileActionsBottomSheet(
      BuildContext context, Map<String, dynamic> fileData) {
    final fileName = fileData['name'] as String? ?? 'Unnamed';
    final fileIcon = _getFileIcon(fileName);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(fileIcon, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
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
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(Icons.edit, color: Colors.black),
              title: Text('Rename',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, fileData);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(Icons.folder_open, color: Colors.black),
              title: Text('Move',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _moveFile(context, fileData);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(Icons.delete, color: Colors.black),
              title: Text('Delete',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteFileDialog(context, fileData);
              },
            ),
            SizedBox(height: 10),
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
          title: Center(
            child: Text("Rename File",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "New Name",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding:
              EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF1A62B7)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Color(0xFF1A62B7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      await _renameFile(fileData, newName);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A62B7),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
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
    final fId =
        fileData['folderId'] as String; // original folderId from file data
    final filePath = fileData['filePath'];

    // Update in original folder
    final fileDoc = await _getFileDocByPath(userId, fId, filePath);
    if (fileDoc != null) {
      await fileDoc.reference.update({'name': newName});
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No other folders available.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectFolderDestinationPage(
          folders: otherFolders,
          onFolderSelected: (targetFolderId) async {
            await _moveFileToFolder(fileData, targetFolderId);
            Navigator.pop(context); // Go back after moving the file
          },
        ),
      ),
    );
  }

  Future<void> _moveFileToFolder(
      Map<String, dynamic> fileData, String targetFolderId) async {
    final userId = currentUser.uid;
    final filePath = fileData['filePath'];
    final oldFolderId = fileData['folderId'];

    // Add to target folder
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .doc(targetFolderId)
        .collection('files')
        .add({
      'name': fileData['name'],
      'filePath': filePath,
      'uploadedAt': fileData['uploadedAt'],
      'folderId': targetFolderId,
    });

    // Remove from original folder
    if (oldFolderId.isNotEmpty) {
      final fileDoc = await _getFileDocByPath(userId, oldFolderId, filePath);
      if (fileDoc != null) {
        await fileDoc.reference.delete();
      }
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
              Text(
                "$fileName will be deleted forever.",
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
                    side: BorderSide(color: Color(0xFF1A62B7)),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Color(0xFF1A62B7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _deleteFile(fileData);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDB0000),
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
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
      String userId, String folderId, String filePath) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .doc(folderId)
        .collection('files')
        .where('filePath', isEqualTo: filePath)
        .limit(1)
        .get();

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
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Center(
            child: Text(
              "Delete Folder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
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
                    side: BorderSide(color: Color(0xFF1A62B7)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Color(0xFF1A62B7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (folderId != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .collection('folders')
                          .doc(folderId!)
                          .delete();
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // go back
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDB0000),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
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
          title: Center(
            child: Text(
              "Edit Folder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: folderNameController,
                  decoration: InputDecoration(
                    hintText: "Folder Name",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding:
              EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
          actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF1A62B7)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Color(0xFF1A62B7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 15),
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
                      backgroundColor: Color(0xFF1A62B7),
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
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

// The SelectFolderDestinationPage remains the same as previously implemented
class SelectFolderDestinationPage extends StatelessWidget {
  final List<QueryDocumentSnapshot> folders;
  final Future<void> Function(String folderId) onFolderSelected;

  SelectFolderDestinationPage({
    Key? key,
    required this.folders,
    required this.onFolderSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.close, color: Colors.black),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          "Select Folder Destination",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: 10),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                final folderData = folder.data() as Map<String, dynamic>;
                final folderName = folderData['name'] as String? ?? 'Unnamed';

                return ListTile(
                  title: Text(folderName),
                  leading: Icon(Icons.folder, color: Color(0xFF1A62B7)),
                  onTap: () async {
                    await onFolderSelected(folder.id);
                  },
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 15),
            ),
          ),
        ],
      ),
    );
  }
}
