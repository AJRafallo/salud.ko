import 'package:flutter/material.dart';
import 'package:saludko/screens/UserSide/profilepage.dart';

class SaludkoAppBar extends StatefulWidget {
  const SaludkoAppBar({super.key});

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
      pinned: true, // Keeps the top part of the app bar visible when scrolling
      expandedHeight: 70.0, // Adjust height as needed
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
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: 20), // Adjusts the space to push content down
            ],
          ),
        ),
      ),
    );
  }
}
