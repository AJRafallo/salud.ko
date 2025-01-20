import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHotlinesScreen extends StatefulWidget {
  const AdminHotlinesScreen({super.key});

  @override
  _AdminHotlinesScreenState createState() => _AdminHotlinesScreenState();
}

class _AdminHotlinesScreenState extends State<AdminHotlinesScreen> {
  final CollectionReference _hotlinesCollection =
      FirebaseFirestore.instance.collection('hotlines');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numbersController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numbersController.dispose();
    super.dispose();
  }

  void _showAddHotlineDialog() {
    _nameController.clear();
    _numbersController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Center(
            child: Text(
              "Add Hotline",
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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Hotline Name",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _numbersController,
                  decoration: const InputDecoration(
                    hintText: "Numbers (comma-separated)",
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
                  onPressed: _addHotline,
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
                    "Add",
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

  Future<void> _addHotline() async {
    final name = _nameController.text.trim();
    final numbers =
        _numbersController.text.split(',').map((e) => e.trim()).toList();

    if (name.isNotEmpty && numbers.isNotEmpty) {
      await _hotlinesCollection.add({
        'name': name,
        'numbers': numbers,
      });

      // Clear & close
      _nameController.clear();
      _numbersController.clear();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showEditHotlineDialog(
      String id, String oldName, List<String> oldNumbers) {
    _nameController.text = oldName;
    _numbersController.text = oldNumbers.join(', ');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Center(
            child: Text(
              "Edit Hotline",
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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Hotline Name",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _numbersController,
                  decoration: const InputDecoration(
                    hintText: "Numbers (comma-separated)",
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
                  onPressed: () => _updateHotline(id),
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
                    "Update",
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

  Future<void> _updateHotline(String id) async {
    final name = _nameController.text.trim();
    final numbers =
        _numbersController.text.split(',').map((e) => e.trim()).toList();

    if (name.isNotEmpty && numbers.isNotEmpty) {
      await _hotlinesCollection.doc(id).update({
        'name': name,
        'numbers': numbers,
      });

      _nameController.clear();
      _numbersController.clear();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showDeleteHotlineDialog(String id, String hotlineName) {
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
              "Delete Hotline",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              const Text(
                "Are you sure you want to delete this hotline?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 10),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _deleteHotline(id);
                    if (mounted) Navigator.pop(context);
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

  Future<void> _deleteHotline(String id) async {
    await _hotlinesCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A62B7),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Hotlines',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Add New Hotline Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _showAddHotlineDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF188b15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Add New Emergency Hotline",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // Hotlines List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _hotlinesCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hotlines available.'));
                }

                final hotlines = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: hotlines.length,
                  itemBuilder: (context, index) {
                    final doc = hotlines[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final hotlineName = data['name'] ?? 'Unknown Hotline';
                    final hotlineNumbers = List<String>.from(
                      data['numbers'] ?? [],
                    );
                    final numbersString = hotlineNumbers.join(' | ');

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1DBE1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotlineName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    numbersString,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.blueGrey,
                                  onPressed: () {
                                    _showEditHotlineDialog(
                                      doc.id,
                                      hotlineName,
                                      hotlineNumbers,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () => _showDeleteHotlineDialog(
                                    doc.id,
                                    hotlineName,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
