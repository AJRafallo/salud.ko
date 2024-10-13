import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/ProviderSide/DetailsPage.dart';
import 'package:saludko/screens/Services/databasehelper.dart'; // Import the DatabaseHelper

class VerifiedProvidersWidget extends StatefulWidget {
  const VerifiedProvidersWidget({super.key});

  @override
  _VerifiedProvidersWidgetState createState() =>
      _VerifiedProvidersWidgetState();
}

class _VerifiedProvidersWidgetState extends State<VerifiedProvidersWidget> {
  final DatabaseHelper _dbHelper =
      DatabaseHelper(); // Initialize DatabaseHelper
  Set<String> _bookmarkedProviders = {}; // Track bookmarked providers

  @override
  void initState() {
    super.initState();
    _loadBookmarkedProviders(); // Load bookmarks from SQLite on initialization
  }

  // Load the bookmarked providers from SQLite
  Future<void> _loadBookmarkedProviders() async {
    final bookmarks = await _dbHelper.getBookmarks();
    setState(() {
      _bookmarkedProviders = bookmarks.map((b) => b['id'] as String).toSet();
    });
  }

  // Toggle bookmark state and store/remove in/from SQLite
  Future<void> _toggleBookmark(
      String providerId, Map<String, dynamic> providerData) async {
    if (_bookmarkedProviders.contains(providerId)) {
      await _dbHelper.removeBookmark(providerId);
    } else {
      await _dbHelper.addBookmark({
      'id': providerId,
      'firstname': providerData['firstname'],
      'lastname': providerData['lastname'], // Include lastname
      'email': providerData['email'],
      'specialization': providerData['specialization'], // Include specialization
      'description': providerData['description'], // Include description
      'phone': providerData['phone'], // Include phone if needed
      'workplace': providerData['workplace'], // Include workplace if needed
      'Address': providerData['Address'], // Include Address if needed
    });
    }
    setState(() {
      if (_bookmarkedProviders.contains(providerId)) {
        _bookmarkedProviders.remove(providerId);
      } else {
        _bookmarkedProviders.add(providerId);
      }
    });
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
                final providerId = providers[index].id; // Get provider ID
                var profileImageUrl = provider['profileImage'] ??
                    ''; // Get provider's profile image URL, if available

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
                      "${provider['specialization']}, ${provider['workplace']}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _bookmarkedProviders.contains(providerId)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: _bookmarkedProviders.contains(providerId)
                            ? Colors.green
                            : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleBookmark(providerId, provider);
                      },
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
