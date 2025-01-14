import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          'Admin Dashboard',
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
                'No unverified providers available.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var provider = snapshot.data!.docs[index];
              return ProviderCard(
                provider: provider.data() as Map<String, dynamic>,
                onVerify: () => _verifyProvider(provider.id),
                onDelete: () => _removeProvider(provider.id),
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
        .update({'isVerified': true}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider verified successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify provider: $error')),
      );
    });
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('healthcare_providers')
                    .doc(providerId)
                    .delete()
                    .then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Provider removed')),
                  );
                }).catchError((error) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to remove provider: $error')),
                  );
                });
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final VoidCallback onVerify;
  final VoidCallback onDelete;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.onVerify,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            if (provider['companyIDPath'] != null)
              GestureDetector(
                onTap: () => _showImageDialog(context, provider['companyIDPath']),
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
              'Dr. ${provider['firstname']} ${provider['lastname']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              provider['email'],
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onVerify,
                  child: const Text('Verify'),
                ),
                ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
