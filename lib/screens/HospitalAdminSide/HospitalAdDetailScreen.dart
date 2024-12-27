import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saludko/screens/widget/ListbyWorkplace.dart';
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
      backgroundColor: const Color.fromARGB(255, 222, 237, 255),
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
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                child: Container(
                  width: 500, // Adjust width
                  height: 300, // Adjust height
                  decoration: BoxDecoration(
                    image: profileImageUrl != null &&
                            profileImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profileImageUrl!),
                            fit: BoxFit
                                .cover, // Ensures the image covers the container
                          )
                        : const DecorationImage(
                            image: AssetImage('lib/assets/images/avatar.png'),
                            fit: BoxFit.cover,
                          ),
                    color: Colors.grey[
                        300], // Background color if image is not available
                  ),
                  child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.grey)
                      : null, // Show camera icon if no profile image is available
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.facility['workplace']?.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A62B7),
                          ),
                        ),
                        Text(
                          '${widget.facility['address']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'CONTACT INFORMATION',
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
                  const SizedBox(height: 20),
                  ProviderListByWorkplace(
                      workplace: widget.facility['workplace']),

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
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 20.0),
                        decoration: ShapeDecoration(
                          color: Colors.blue, // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Rounded corners
                          ),
                        ),
                        child: const Text(
                          'View on Map',
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 15,
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Delete button for admin users
                  if (currentUserRole ==
                      'admin') // Adjust based on your role-checking logic
                    ElevatedButton(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
