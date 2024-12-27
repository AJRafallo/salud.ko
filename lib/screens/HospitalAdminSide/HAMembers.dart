import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/DetailsPage.dart';

class HAMembers extends StatefulWidget {
  final String workplace;

  const HAMembers({super.key, required this.workplace});

  @override
  State<HAMembers> createState() => _HAMembersState();
}

class _HAMembersState extends State<HAMembers> {
  final Map<String, bool> _seeMoreState = {}; // Tracks the "See More" state for each category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Members',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('healthcare_providers')
            .where('isVerified', isEqualTo: true)
            .where('workplace', isEqualTo: widget.workplace)
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
              ),
            );
          }

          final providers = snapshot.data!.docs;
          final Map<String, List<QueryDocumentSnapshot>> categorizedProviders = {};

          // Group providers by specialization
          for (var providerDoc in providers) {
            final provider = providerDoc.data() as Map<String, dynamic>;
            final specialization = provider['specialization'] ?? 'General';

            if (!categorizedProviders.containsKey(specialization)) {
              categorizedProviders[specialization] = [];
            }
            categorizedProviders[specialization]!.add(providerDoc);
          }

          return ListView(
            children: 
            categorizedProviders.entries.map((entry) {
              final specialization = entry.key;
              final providerDocs = entry.value;
              final isExpanded = _seeMoreState[specialization] ?? false;

              return Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                      color: const Color(0xFFD1DBE1),
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Text(
                        specialization,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    ...providerDocs.take(isExpanded ? providerDocs.length : 3).map((providerDoc) {
                      final provider = providerDoc.data() as Map<String, dynamic>;
                      var profileImageUrl = provider['profileImage'] ?? '';
                
                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                      color: const Color(0xFFDEEDFF),
                      borderRadius:
                          BorderRadius.circular(25), // Rounded corners
                    ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage('lib/assets/images/avatar.png')
                                    as ImageProvider,
                            onBackgroundImageError: (_, __) {
                              setState(() {
                                profileImageUrl = '';
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProviderDetailScreen(provider: provider),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                    if (providerDocs.length > 3)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _seeMoreState[specialization] = !isExpanded;
                            });
                          },
                          child: Text(isExpanded ? 'See Less' : 'See More'),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
