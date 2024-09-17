import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/widget/hospitaladbotnav.dart';
import 'package:saludko/screens/widget/provappbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HospitalAdHomeScreen extends StatelessWidget {
  const HospitalAdHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hospital')
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
            return const Center(child: Text('Provider data not found.'));
          }

          final provider = snapshot.data!.data() as Map<String, dynamic>;

          return CustomScrollView(
            slivers: [
              SaludkoProvAppBar(
                provider: provider, 
                providerId: currentUser.uid, // Pass the provider's UID here
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 1500, 20, 20),
                        child: Column(
                          children: [
                            Text(
                              "This is the Hospital Admin HomeScreen",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Add more widgets as needed
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const Hospitaladbotnav(),
    );
  }
}
