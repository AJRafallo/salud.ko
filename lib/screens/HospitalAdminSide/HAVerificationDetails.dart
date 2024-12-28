import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:saludko/screens/widget/provmapscreen.dart';

class ProviderVerificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const ProviderVerificationDetailScreen({super.key, required this.provider});

  @override
  _ProviderVerificationDetailScreenState createState() =>
      _ProviderVerificationDetailScreenState();
}

class _ProviderVerificationDetailScreenState
    extends State<ProviderVerificationDetailScreen> {
  String? profileImageUrl;
  String? currentUserUid;
  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    profileImageUrl = widget.provider['profileImage'];
    _getCurrentUserUid();
  }

  Future<void> _getCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserUid = user.uid;
      });
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('hospital_admin')
          .doc(user.uid)
          .get();
      setState(() {
        currentUserRole = userDoc['role'];
      });
    }
  }

  Future<void> _uploadImage() async {
    if (currentUserUid != widget.provider['uid']) {
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
            .child('provider_images/${widget.provider['uid']}.jpg');

        await storageRef.putFile(File(image.path));
        profileImageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('healthcare_providers')
            .doc(widget.provider['uid'])
            .update({'profileImage': profileImageUrl});

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _deleteProvider() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this profile?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('healthcare_providers')
            .doc(widget.provider['uid'])
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider deleted successfully.')),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete provider: $e')),
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
              'Healthcare Provider Profile',
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
        padding: const EdgeInsets.all(16.0),
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
                  onTap: _uploadImage,
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
                      child: Text(
                        'Dr. ${widget.provider['firstname'] ?? '[No firstname provided]'} ${widget.provider['lastname'] ?? '[No lastname provided]'}',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A62B7),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${widget.provider['specialization'] ?? '[No specialization provided]'}, ${widget.provider['workplace'] ?? '[No workplace provided]'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${widget.provider['description'] ?? '[No description provided]'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Doctor\'s Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${widget.provider['email'] ?? '[No email provided]'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Phone: ${widget.provider['phone'] ?? '[No phone number provided]'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Workplace: ${widget.provider['workplace'] ?? '[No workplace provided]'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Address: ${widget.provider['Address'] ?? '[No address provided]'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    // Displaying the company ID
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Company ID:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        widget.provider['companyIDPath'] != null &&
                                widget.provider['companyIDPath']!.isNotEmpty
                            ? Image.network(
                                widget.provider[
                                    'companyIDPath'], // URL of the company ID image
                                height: 200, // You can adjust the height
                                width:
                                    double.infinity, // Adjust width if needed
                                fit: BoxFit
                                    .cover, // Set how the image should fit within the container
                              )
                            : const Text('[No company ID provided]'),
                      ],
                    ),

                    InkWell(
                      onTap: () async {
                        final String workplace =
                            widget.provider['workplace'] ?? '';
                        final GeoPoint? facilityLocation =
                            await getFacilityLocation(workplace);

                        if (facilityLocation != null) {
                          final double latitude = facilityLocation.latitude;
                          final double longitude = facilityLocation.longitude;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProvMapScreen(
                                latitude: latitude,
                                longitude: longitude,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Facility location not found.')),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20.0),
                          decoration: ShapeDecoration(
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'View on Map',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (currentUserRole == 'admin') ...[
                      Center(
                        child: ElevatedButton(
                          onPressed: _deleteProvider,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Delete Profile'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<GeoPoint?> getFacilityLocation(String workplace) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('hospital')
        .where('workplace', isEqualTo: workplace)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('location') as GeoPoint?;
    }
    return null;
  }
}