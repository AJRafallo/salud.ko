import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/HospitalAdminSide/HospitalAdDetailScreen.dart';

class AdminMembers extends StatelessWidget {
  const AdminMembers({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Manage Members',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A62B7),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admins')
            .doc(currentUser.uid) // Use the logged-in user's ID to get their data
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Admin data not found.'));
          }

          final admin = snapshot.data!.data() as Map<String, dynamic>;

          // Hospital Listing Section
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('hospital') // Your Firestore collection for hospitals
                .snapshots(),
            builder: (context, hospitalSnapshot) {
              if (hospitalSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (hospitalSnapshot.hasError) {
                return Center(child: Text('Error: ${hospitalSnapshot.error}'));
              }

              if (!hospitalSnapshot.hasData || hospitalSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No hospitals found.'));
              }

              final hospitals = hospitalSnapshot.data!.docs;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Manage Partner Hospitals & Clinics",
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: hospitals.length,
                            itemBuilder: (context, index) {
                              final hospital = hospitals[index].data() as Map<String, dynamic>;

                              var profileImageUrl = hospital['profileImage'] ?? ''; // Get hospital's profile image URL

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to the provider detail screen
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HospitalAdDetailScreen(facility: hospital),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Profile Image as Rectangular Container
                                      SizedBox(
                                        width: 300, // Adjust the width
                                        height: 200, // Adjust the height
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            image: DecorationImage(
                                              image: profileImageUrl.isNotEmpty
                                                  ? NetworkImage(profileImageUrl)
                                                  : const AssetImage(
                                                          'lib/assets/images/avatar.png')
                                                      as ImageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: (profileImageUrl.isEmpty)
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 5),

                                      // Hospital Name
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              hospital['workplace'],
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 5),

                                            // Hospital Address
                                            Text(
                                              hospital['address']?.length > 50
                                                  ? '${hospital['address']?.substring(0, 50)}...'
                                                  : hospital['address'] ?? '',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
