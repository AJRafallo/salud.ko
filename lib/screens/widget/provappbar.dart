import 'package:flutter/material.dart';
import 'package:saludko/screens/UserSide/profilepage.dart';

class SaludkoProvAppBar extends StatefulWidget {
  const SaludkoProvAppBar({super.key});

  @override
  _SaludkoProvAppBarState createState() => _SaludkoProvAppBarState();
}

class _SaludkoProvAppBarState extends State<SaludkoProvAppBar> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.blueAccent,
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
                  builder: (context) => const ProfilePage(),
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
      flexibleSpace: const FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello!",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Welcome to salud.ko",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20), // Space between the text and search box
            ],
          ),
        ),
      ),
    );
  }
}
