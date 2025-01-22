import 'package:flutter/material.dart';
import 'package:saludko/screens/UserSide/UProfile.dart';
import 'package:saludko/screens/widget/MedicineReminders/notifications.dart';

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
      pinned: true,
      expandedHeight: 70.0,
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
          Row(
            children: [
              // Notification Bell Icon
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.notifications,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              // Profile icon
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
        ],
      ),
      flexibleSpace: const FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
