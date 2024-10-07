import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/widget/VerifList2.dart';
import 'package:saludko/screens/widget/adminappbar.dart';
import 'package:saludko/screens/widget/adminbotnav.dart';
import 'package:saludko/screens/widget/healthcarefacilitieslist.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

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

          final admin = snapshot.data!.data() as Map<String, dynamic>;

          return const CustomScrollView(
              slivers: [
                AdminAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Healthcare Facilities",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                              ),
                            ),
                            HealthcareFacilities(),
                            SizedBox(height: 10),
                            Text(
                              "Healthcare Providers",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                              ),
                            ),
                            VerifiedProvidersWidget2(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
          );
        },
      ),
      bottomNavigationBar: const Adminbotnav(),
    );
  }
}
