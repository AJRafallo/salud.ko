import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/DetailsPage.dart';
import 'package:saludko/screens/Services/databasehelper.dart';
import 'package:saludko/screens/widget/appbar_2.dart';

class SavedScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Accept userData
  final String userId; // Accept userId

  const SavedScreen({
    super.key,
    required this.userData,
    required this.userId,
  });

  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _bookmarkedProviders = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarkedProviders(); // Load bookmarks on initialization
  }

  // Load bookmarks from SQLite
  Future<void> _loadBookmarkedProviders() async {
    final bookmarks = await _dbHelper.getBookmarks();
    for (var bookmark in bookmarks) {
      print(
          "Bookmark ID: ${bookmark['id']}, Profile Image: ${bookmark['profileImage']}");
    }
    setState(() {
      _bookmarkedProviders = bookmarks;
    });
  }

  // Remove a provider from bookmarks (unbookmark)
  Future<void> _removeBookmark(String providerId) async {
    await _dbHelper.removeBookmark(providerId); // Remove from SQLite
    _loadBookmarkedProviders(); // Reload the updated list after removal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Provider removed from bookmarks.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SaludkoAppBar(), // Corrected app bar usage
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Saved Profiles",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (_bookmarkedProviders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "You have no saved healthcare providers available.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _bookmarkedProviders.length,
                          itemBuilder: (context, index) {
                            final provider = _bookmarkedProviders[index];
                            var profileImageUrl = provider['profileImage'] ??
                                ''; // Get provider's profile image URL, if available
                            print('Provider: $provider'); // Debugging
                            print(
                                'Provider Image URL: $profileImageUrl'); // Debugging

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1DBE1),
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
                                      : const AssetImage(
                                              'lib/assets/images/avatar.png')
                                          as ImageProvider,
                                  onBackgroundImageError: (error, stackTrace) {
                                    print(
                                        'Error loading image: $error'); // Log the error
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
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.bookmark,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    _removeBookmark(
                                        provider['id']); // Remove bookmark
                                  },
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProviderDetailScreen(
                                              provider: provider),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}