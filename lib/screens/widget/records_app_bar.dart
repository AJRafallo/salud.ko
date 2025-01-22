import 'package:flutter/material.dart';
import 'package:saludko/screens/UserSide/UProfile.dart';
import 'package:saludko/screens/widget/MedicineReminders/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              _buildNotificationBell(context),
              const SizedBox(width: 16),
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

  /// Builds the bell icon with a small red dot if there are any unread notifications.
  Widget _buildNotificationBell(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // User not logged in -> show plain bell icon.
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const NotificationsScreen()),
        ),
        child: const Icon(Icons.notifications, size: 30, color: Colors.white),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      // Listen only to 'unread' notifications.
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('status', isEqualTo: 'unread')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Data not yet loaded -> show plain bell icon.
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const NotificationsScreen()),
            ),
            child:
                const Icon(Icons.notifications, size: 30, color: Colors.white),
          );
        }

        final hasUnread = snapshot.data!.docs.isNotEmpty;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const NotificationsScreen()),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications, size: 30, color: Colors.white),
              if (hasUnread)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
