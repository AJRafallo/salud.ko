import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('hospital')
            .doc(userId)
            .get();

        if (doc.exists) {
          setState(() {
            adminWorkplace = doc['workplace'];
            isLoading = false;
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
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        toolbarHeight: 80,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Verify Providers',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('healthcare_providers')
                        .where('isVerified', isEqualTo: false)
                        .where('workplace', isEqualTo: adminWorkplace)
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
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(20),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  provider['companyIDPath'] != null
                                      ? GestureDetector(
                                          onTap: () {
                                            _showImageDialog(
                                              context,
                                              provider['companyIDPath'],
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.network(
                                              provider['companyIDPath'],
                                              width: 300,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  const SizedBox(height: 10),
                                  Column(
                                    children: [
                                      Column(
                                        
                                        children: [
                                          Text(
                                            'Dr. ${provider['firstname']} ${provider['lastname']}, ${provider['specialization']}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            provider['email'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _verifyProvider(provider.id);
                                            },
                                            child: const Text('Verify'),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              _removeProvider(provider.id);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              iconColor: Colors.red,
                                            ),
                                            child: const Text('Remove'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _verifyProvider(String providerId) {
    FirebaseFirestore.instance
        .collection('healthcare_providers')
        .doc(providerId)
        .update({'isVerified': true});
  }

  // Method to remove the provider
  void _removeProvider(String providerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Provider'),
          content: const Text('Are you sure you want to remove this provider?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('healthcare_providers')
                    .doc(providerId)
                    .delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Provider removed successfully')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String companyIdPath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent, // Transparent background
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close dialog on tap
          },
          child: Center(
            child: Image.network(
              companyIdPath,
              width: 500, // Fixed width
              height: 500, // Fixed height
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error), // Handle errors
            ),
          ),
        ),
      );
    },
  );
}

}
