import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/ProviderSide/DetailsPage.dart';

class VerifiedProvidersWidget2 extends StatefulWidget {
  const VerifiedProvidersWidget2({super.key});

  @override
  _VerifiedProvidersWidget2State createState() =>
      _VerifiedProvidersWidget2State();
}

class _VerifiedProvidersWidget2State extends State<VerifiedProvidersWidget2> {
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
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider =
                    providers[index].data() as Map<String, dynamic>;
                var profileImageUrl = provider['profile_image'] ?? ''; // Get provider's profile image URL, if available

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
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
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage('lib/assets/images/avatar.png')
                              as ImageProvider,
                      onBackgroundImageError: (_, __) {
                        // Fallback to default avatar if there's an error loading the image
                        setState(() {
                          profileImageUrl =
                              ''; // Reset to show the default avatar
                        });
                      },
                    ),
                    title: Text(
                      provider['firstname'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      provider['email'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
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
