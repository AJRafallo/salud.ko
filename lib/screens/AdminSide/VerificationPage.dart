import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
            return const Center(child: Text('No unverified healthcare providers found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var provider = snapshot.data!.docs[index];
              return ListTile(
                title: Text(provider['name']),
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
    );
  }

  void _verifyProvider(String providerId) {
    FirebaseFirestore.instance
        .collection('healthcare_providers')
        .doc(providerId)
        .update({'isVerified': true});
  }
}
