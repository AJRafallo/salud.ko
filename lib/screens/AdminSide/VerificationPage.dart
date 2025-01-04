import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
        title: const Text(
          'Verify Providers',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF1A62B7),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('healthcare_providers')
            .where('isVerified', isEqualTo: false)
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var provider = snapshot.data!.docs[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.blueGrey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          if (provider['companyIDPath'] != null)
                            GestureDetector(
                              onTap: () {
                                _showImageDialog(
                                    context, provider['companyIDPath']);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  provider['companyIDPath'],
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            'Dr. ${provider['firstname']} ${provider['lastname']}, ${provider['specialization']}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            provider['email'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Wrap(
                                spacing: 10,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _verifyProvider(provider.id);
                                    },
                                    child: const Text('Verify'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _removeProvider(provider.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Remove'),
                                  ),
                                ],
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
    );
  }

  void _verifyProvider(String providerId) {
    FirebaseFirestore.instance
        .collection('healthcare_providers')
        .doc(providerId)
        .update({'isVerified': true});
  }

  void _removeProvider(String providerId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Provider'),
          content: const Text('Are you sure you want to remove this provider?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('healthcare_providers')
                    .doc(providerId)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Provider removed')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String companyIDPath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.network(
              companyIDPath,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
