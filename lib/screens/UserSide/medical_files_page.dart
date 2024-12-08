import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/UploadRecords.dart';
// not connected yet
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalFilesPage extends StatefulWidget {
  const MedicalFilesPage({super.key});

  @override
  _MedicalFilesPageState createState() => _MedicalFilesPageState();
}

class _MedicalFilesPageState extends State<MedicalFilesPage> {
  final user = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> defaultFolders = [
    {"name": "All Files"},
    {"name": "Lab Results / Tests"},
    {"name": "Medications"},
    {"name": "Conditions & Problems"},
    {"name": "Notes"},
  ];

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _setupDefaultFolders(user!.uid);
    }
  }

  // Ensure default folders exist
  Future<void> _setupDefaultFolders(String userId) async {
    final userFolders = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders');

    final existingFolders = await userFolders.get();
    if (existingFolders.docs.isNotEmpty) return;

    for (var folder in defaultFolders) {
      await userFolders.add({
        "name": folder["name"],
        "isDefault": true,
        "createdAt": Timestamp.now(),
      });
    }
  }

  // Fetch and sort folders dynamically from Firestore
  Stream<List<Map<String, dynamic>>> _getUserFolders(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .snapshots()
        .map((snapshot) {
      final allFolders =
          snapshot.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();

      // Separate and sort folders
      final defaultFolders =
          allFolders.where((folder) => folder["isDefault"] ?? false).toList();
      final customFolders =
          allFolders.where((folder) => !(folder["isDefault"] ?? false)).toList()
            ..sort((a, b) {
              final aTime = a["createdAt"] as Timestamp;
              final bTime = b["createdAt"] as Timestamp;
              return aTime.compareTo(bTime);
            });

      return [...defaultFolders, ...customFolders];
    });
  }

  // Create New Folder
  Future<void> _showCreateFolderDialog(String userId) async {
    final TextEditingController folderNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Center(
            child: Text(
              "Create New Folder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Opacity(
                    opacity: 0.7,
                    child: ElevatedButton(
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
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () async {
                      final folderName = folderNameController.text.trim();
                      if (folderName.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('folders')
                            .add({
                          "name": folderName,
                          "isDefault": false,
                          "createdAt": Timestamp.now(),
                        });
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
                      "Create",
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getUserFolders(user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final folders = snapshot.data ?? [];

                    return GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      padding: const EdgeInsets.all(8.0),
                      children: [
                        ...folders.map((folder) {
                          return _buildFolder(
                            context: context,
                            label: folder["name"],
                            isDeletable: folder["isDefault"] ?? false == false,
                            onTap: () => _navigateToFolder(
                              context,
                              folder["name"],
                              folder["isDefault"] ?? false,
                              folder["id"],
                            ),
                          );
                        }),
                        _buildFolder(
                          context: context,
                          label: "Create Folder",
                          icon: Icons.add,
                          isCreateFolder: true,
                          onTap: () => _showCreateFolderDialog(user!.uid),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const UploadWidget(),
            ],
          ),
        ],
      ),
    );
  }

  // Navigate to folder content
  void _navigateToFolder(BuildContext context, String folderName,
      bool isDefault, String folderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderContentPage(
          folderName: folderName,
          isDeletable: !isDefault,
          folderId: folderId,
        ),
      ),
    );
  }

  // Folders UI
  Widget _buildFolder({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    bool isDeletable = false,
    IconData icon = Icons.folder,
    bool isCreateFolder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDEEDFF),
          border: Border.all(color: const Color(0xFF9ECBFF), width: 1.5),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 25.0,
              color: isCreateFolder
                  ? const Color(0xFF2555FF)
                  : const Color(0xFF555555),
            ),
            const SizedBox(height: 6.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Folder Content Page with Delete Button for Custom Folders
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(folderName)),
      body: Center(
        child: isDeletable
            ? ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Delete Folder"),
                        content: const Text(
                            "Are you sure you want to delete this folder?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('folders')
                                  .doc(folderId)
                                  .delete();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Delete Folder"),
              )
            : const Text("This folder cannot be deleted."),
      ),
    );
  }
}
