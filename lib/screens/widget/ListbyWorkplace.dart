import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/ProviderSide/DetailsPage.dart';

class ProviderListByWorkplace extends StatefulWidget {
  final String workplace; // Facility workplace

  const ProviderListByWorkplace(
      {super.key, required this.workplace}); // Require workplace

  @override
  _ProviderListByWorkplaceState createState() =>
      _ProviderListByWorkplaceState();
}

class _ProviderListByWorkplaceState extends State<ProviderListByWorkplace> {
  bool showAll = false; // Toggle to show all items

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('healthcare_providers')
          .where('isVerified', isEqualTo: true)
          .where('workplace',
              isEqualTo: widget.workplace) // Filter by workplace
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.only(top: 0),
            child: Text('No verified healthcare providers available.'),
          ));
        }

        final providers = snapshot.data!.docs;
        int itemCount = showAll
            ? providers.length
            : (providers.length > 2 ? 2 : providers.length);

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "AVAILABLE DOCTORS",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (providers.length > 2)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAll =
                              !showAll; // Toggle to show all or fewer items
                        });
                      },
                      child: Text(
                        showAll ? 'Show Less' : 'See More',
                        style: const TextStyle(
                          color: Color(0xFF1A62B7),
                        ),
                      ),
                    ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(66, 255, 255, 255),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final provider =
                          providers[index].data() as Map<String, dynamic>;
                      var profileImageUrl = provider['profileImage'] ?? '';

                      return ListTile(
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
                          "Dr. ${provider['firstname']}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          provider['specialization'],
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
