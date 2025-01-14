import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/AdminSide/AFeedback.dart';
import 'package:saludko/screens/AdminSide/AMembers.dart';
import 'package:saludko/screens/AdminSide/AProfile.dart';
import 'package:saludko/screens/AdminSide/VerificationPage.dart';
import 'package:saludko/screens/widget/VerifList2.dart';
import 'package:saludko/screens/widget/adminappbar.dart';
import 'package:saludko/screens/widget/healthcarefacilitieslist.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHP extends StatelessWidget {
  const AdminHP({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admins')
            .doc(currentUser
                .uid) // Use the logged-in user's ID to get their data
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

          final admin = snapshot.data!.data() as Map<String, dynamic>;
          var profileImageUrl = admin['profileImage'] ?? '';

          return CustomScrollView(
            slivers: [
              const AdminAppBar(),
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
                                            const AdminShowProfile()),
                                  );
                                },
                                child: Column(
                                                                        mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                  children: [
                                    Container(
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
                                                    const AdminShowProfile()),
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
                                              admin['firstname'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              admin['Address'] ??
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                                                    const AdminMembers()),
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
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminDashboard()),
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 320,
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
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FeedbackFeed()),
                                    );
                                  },
                                  child: const Column(
                                    children: [
                                      Icon(
                                        Icons.feedback_rounded,
                                        size: 30,
                                      ),
                                      Text(
                                        "salud.ko Feedbacks",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
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
