import 'package:flutter/material.dart';
import 'package:saludko/screens/UserSide/UProfile.dart';

class SaludkoAppBar extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const SaludkoAppBar({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  _SaludkoAppBarState createState() => _SaludkoAppBarState();
}

class _SaludkoAppBarState extends State<SaludkoAppBar> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF1A62B7),
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      pinned: true, // Keeps the top part of the app bar visible when scrolling
      expandedHeight: 150.0, // Adjust height as needed
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "salud.ko",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShowProfilePage(),
                ),
              );
            },
            child: const Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0), // Adjusts the space to push content down
              Text(
                "Hello, ${widget.userData['firstname']}!", // Display user's first name
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Welcome to salud.ko",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              /* Uncomment this to include the search field
              const SizedBox(height: 20), // Space between the text and search box
              InputTextField(
                textEditingController: searchController,
                hintText: "Search",
                icon: Icons.search,
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}
