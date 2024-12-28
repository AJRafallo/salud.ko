import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saludko/screens/HospitalAdminSide/HAMembers.dart';
import 'package:saludko/screens/HospitalAdminSide/HAProfile.dart';
import 'package:saludko/screens/HospitalAdminSide/HospitalAdVerificationPage.dart';
import 'package:saludko/screens/widget/VerifList2.dart';
import 'package:saludko/screens/widget/adminappbar2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/healthcarefacilitieslist.dart';

class HAdminHomeScreen extends StatefulWidget {
  const HAdminHomeScreen({super.key});

  @override
  State<HAdminHomeScreen> createState() => _HAdminHomeScreenState();
}

class _HAdminHomeScreenState extends State<HAdminHomeScreen> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('hospital')
          .doc(currentUser.uid)
          .get();
      if (doc.exists) {
        setState(() {
          profileImageUrl = doc.data()?['profileImage'];
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) return;

        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('facility_images/${currentUser.uid}.jpg');

        await storageRef.putFile(File(image.path));
        // Get the download URL
        final downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with new profile image URL
        await FirebaseFirestore.instance
            .collection('hospital')
            .doc(currentUser.uid)
            .update({'profileImage': downloadUrl});

        setState(() {
          profileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hospital')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Provider data not found.'));
          }

          final hospital = snapshot.data!.data() as Map<String, dynamic>;
          profileImageUrl = hospital['profileImage'];

          return CustomScrollView(
            slivers: [
              AdminAppBar2(
                hospital: hospital,
                hospitalId: currentUser.uid,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                "PROFILE CARD",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HospitalAdShowProfile()),
                                  );
                                },
                                child: Container(
                                  width: 325,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFDEEDFF), // Light blue
                                        Color.fromARGB(255, 115, 146,
                                            176), // Slightly darker blue
                                        Color(
                                            0xFFFFFFFF), // White for metallic shine
                                        Color(
                                            0xFFA6CBE3), // Subtle shadow effect
                                      ],
                                      stops: [0.0, 0.3, 0.7, 1.0],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HospitalAdShowProfile()),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundImage: profileImageUrl !=
                                                      null &&
                                                  profileImageUrl!.isNotEmpty
                                              ? NetworkImage(profileImageUrl!)
                                              : const AssetImage(
                                                  'lib/assets/images/avatar.png',
                                                ) as ImageProvider,
                                          child: (profileImageUrl == null ||
                                                  profileImageUrl!.isEmpty)
                                              ? const Icon(
                                                  Icons.camera_alt,
                                                  size: 40,
                                                  color: Colors.grey,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          hospital['workplace'] ??
                                              'Hospital Admin',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          hospital['address'] ??
                                              'No address assigned',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 155,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                         HAMembers(workplace: "${hospital['workplace']}",)),
                              );
                            },
                                  child: const Column(children: [
                                Icon(
                                  Icons.group_rounded,
                                  size: 30,
                                ),
                                Text(
                                  "Members",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ])),
                            ],
                          ),
                        ),
                        Container(
                          width: 155,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 1,
                          ),
                        ],),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HospitalAdDashboard()),
                              );
                            },
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 30,
                                ),
                                Text(
                                  "Verify",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Partner Hospitals & Clinics",
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          HealthcareFacilities(),
                          SizedBox(height: 20),
                          Text(
                            "Partner Healthcare Professionals",
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          VerifiedProvidersWidget2(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
