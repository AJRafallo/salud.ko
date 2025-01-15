import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:saludko/screens/widget/mapscreen.dart';

class HospitalAdDetailScreen extends StatefulWidget {
  final Map<String, dynamic> facility;

  const HospitalAdDetailScreen({super.key, required this.facility});

  @override
  _HospitalAdDetailScreenState createState() => _HospitalAdDetailScreenState();
}

class _HospitalAdDetailScreenState extends State<HospitalAdDetailScreen> {
  String? profileImageUrl;
  String? currentUserUid;
  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    profileImageUrl = widget.facility['profileImage'];
    _getCurrentUserUid();
  }

  Future<void> _getCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserUid = user.uid;
      });
      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid) // Replace with your collection and document structure
          .get();
      setState(() {
        currentUserRole =
            userDoc['role']; // Adjust based on your Firestore structure
      });
    }
  }

  Future<void> _uploadImage() async {
    // Check if the current user is authorized to upload the image
    if (currentUserUid != widget.facility['uid']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You are not authorized to edit this profile.')),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('facility_images/${widget.facility['uid']}.jpg');

        await storageRef.putFile(File(image.path));
        profileImageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('hospital')
            .doc(widget.facility['uid'])
            .update({'profileImage': profileImageUrl});

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _deleteFacility() async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this profile?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // User clicked No
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // User clicked Yes
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    // If the user confirmed the deletion, proceed
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('hospital')
            .doc(widget.facility['uid'])
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facility deleted successfully.')),
        );

        // Navigate back or to a different screen after deletion
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete facility: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A62B7),
        title: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: const Text(
              'Healthcare Facility Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xFF1A62B7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : const AssetImage('lib/assets/images/avatar.png')
                                as ImageProvider,
                    child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? const Icon(Icons.camera_alt,
                            size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Text(
                              '${widget.facility['workplace']}',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${widget.facility['address']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'FACILITY INFORMATION',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Icon(
                            Icons.email_rounded,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${widget.facility['email']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Icon(
                            Icons.call_rounded,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${widget.facility['phone']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // Button to open MapScreen
                    InkWell(
                      onTap: () {
                        // Extract latitude and longitude from the Firestore document
                        final GeoPoint location = widget.facility['location'];
                        final double latitude = location.latitude;
                        final double longitude = location.longitude;

                        // Navigate to MapScreen, passing the latitude and longitude
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              latitude: latitude,
                              longitude: longitude,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 50),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF1A62B7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'View Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Delete button for admin users
              if (currentUserRole ==
                  'admin') // Adjust based on your role-checking logic
                Center(
                  child: ElevatedButton(
                    onPressed: _deleteFacility,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Change color to red for deletion
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 30.0),
                    ),
                    child: const Text(
                      'Delete Facility',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
