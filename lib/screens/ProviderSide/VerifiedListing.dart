import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/ProviderSide/DetailsPage.dart';

class VerifiedProvidersWidget extends StatelessWidget {
  const VerifiedProvidersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('healthcare_providers')
          .where('isVerified', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No verified healthcare providers available.'));
        }

        final providers = snapshot.data!.docs;

        return Column(
          children: [
            const Padding(padding: EdgeInsets.all(10)), 
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              shrinkWrap:
                  true, // Ensures the ListView only takes up as much space as needed
              physics:
                  const NeverScrollableScrollPhysics(), // Prevents scrolling within the container
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider =
                    providers[index].data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5.0), // Spacing between list items
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color of the container
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 2), // Shadow offset
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(provider['firstname']),
                    subtitle: Text(provider['email']),
                    onTap: () {
                      // Navigate to the provider detail screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProviderDetailScreen(provider: provider),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
