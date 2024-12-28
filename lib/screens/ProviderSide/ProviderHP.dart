import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/PProfile.dart';
import 'package:saludko/screens/widget/VerifList2.dart';
import 'package:saludko/screens/widget/healthcarefacilitieslist.dart';
import 'package:saludko/screens/widget/provappbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProviderHP extends StatefulWidget {
  const ProviderHP({super.key});

  @override
  State<ProviderHP> createState() => _ProviderHPState();
}

class _ProviderHPState extends State<ProviderHP> {
  String? profileImageUrl;
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _uploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('provider_images/${currentUser!.uid}.jpg');

        await storageRef.putFile(File(image.path));
        // Get the download URL
        profileImageUrl = await storageRef.getDownloadURL();
        // Update Firestore with new profile image URL
        await FirebaseFirestore.instance
            .collection('healthcare_providers')
            .doc(currentUser!.uid)
            .update({'profileImage': profileImageUrl});

        setState(() {}); // Update the UI to show the new image
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('healthcare_providers')
              .doc(currentUser!.uid)
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

            final provider = snapshot.data!.data() as Map<String, dynamic>;

            // Load the profile image URL from Firestore, if not already set
            if (profileImageUrl == null && provider['profileImage'] != null) {
              profileImageUrl = provider['profileImage'];
            }

            return CustomScrollView(
              slivers: [
                SaludkoProvAppBar(
                  provider: provider,
                  providerId: currentUser!.uid, // Pass the provider's UID here
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                              const ProviderShowProfile()),
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
                                                  const ProviderShowProfile()),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundImage:
                                                profileImageUrl != null &&
                                                        profileImageUrl!
                                                            .isNotEmpty
                                                    ? NetworkImage(
                                                        profileImageUrl!)
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
                                            "${provider['lastname']}, ${provider['firstname']}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${provider['specialization']}, ${provider['workplace']}",
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
          }),
    );
  }
}

Future<GeoPoint?> getFacilityLocation(String workplace) async {
  final QuerySnapshot facilitySnapshot = await FirebaseFirestore.instance
      .collection('hospital')
      .where('workplace', isEqualTo: workplace)
      .get();

  if (facilitySnapshot.docs.isNotEmpty) {
    // Assuming location is stored as a GeoPoint in your facility documents
    final facilityData =
        facilitySnapshot.docs.first.data() as Map<String, dynamic>;
    return facilityData['location'] as GeoPoint?;
  }
  return null; // Return null if no facility is found
}
