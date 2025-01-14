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
  String toSentenceCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

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
                var profileImageUrl = provider['profileImage'] ?? ''; // Get provider's profile image URL, if available

                // Apply Sentence Case
                final firstname = toSentenceCase(provider['firstname'] ?? '');
                final lastname = toSentenceCase(provider['lastname']?? '');
                final specialization =
                    toSentenceCase(provider['specialization'] ?? '');
                final workplace = toSentenceCase(provider['workplace'] ?? '');

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
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
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage('lib/assets/images/avatar.png')
                              as ImageProvider,
                      onBackgroundImageError: (_, __) {
                        setState(() {
                          profileImageUrl =
                              ''; // Reset to show the default avatar
                        });
                      },
                    ),
                    title: Text(
                      "Dr. $lastname, $firstname",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "$specialization, $workplace",
                      style: const TextStyle(
                        fontSize: 12,
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
