import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/adminappbar2.dart';
import 'package:saludko/screens/widget/hospitaladbotnav.dart';

class HospitalAdDashboard extends StatefulWidget {
  const HospitalAdDashboard({super.key});

  @override
  _HospitalAdDashboardState createState() => _HospitalAdDashboardState();
}

class _HospitalAdDashboardState extends State<HospitalAdDashboard> {
  String? adminWorkplace; // Store admin's workplace
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminWorkplace(); // Fetch the admin's workplace on initialization
  }

  Future<void> _fetchAdminWorkplace() async {
    try {
      // Assuming that the admin's UID is available through FirebaseAuth
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('hospital')
            .doc(userId) // Assuming hospital admin document ID is the same as user UID
            .get();

        if (doc.exists) {
          setState(() {
            adminWorkplace = doc['workplace']; // Get the admin's workplace
            isLoading = false; // Done loading
          });
        } else {
          print('Admin document does not exist.');
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching admin workplace: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                const AdminAppBar2(), // SliverAppBar
                SliverFillRemaining(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('healthcare_providers')
                        .where('isVerified', isEqualTo: false)
                        .where('workplace', isEqualTo: adminWorkplace) // Filter by admin's workplace
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No unverified healthcare providers found.',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var provider = snapshot.data!.docs[index];
                          return ListTile(
                            title: Text(provider['firstname']),
                            subtitle: Text(provider['email']),
                            trailing: ElevatedButton(
                              onPressed: () {
                                _verifyProvider(provider.id);
                              },
                              child: const Text('Verify'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const Hospitaladbotnav(),
    );
  }

  void _verifyProvider(String providerId) {
    FirebaseFirestore.instance
        .collection('healthcare_providers')
        .doc(providerId)
        .update({'isVerified': true});
  }
}
