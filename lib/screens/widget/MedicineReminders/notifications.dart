import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A62B7),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 1) GET ALL DOCS
          final allDocs = snapshot.data?.docs ?? [];

          // 2) FILTER OUT FUTURE ONES
          final now = DateTime.now();
          // Only include docs whose 'time' <= now
          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp? ts = data['time'] as Timestamp?;
            if (ts == null) return false; // skip if missing time
            final docTime = ts.toDate();
            return !docTime.isAfter(now);
            // means docTime <= now -> show in feed
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text('No notifications available.'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final medicineName = data['medicineName'] ?? 'Unknown Medicine';
              final Timestamp timeStamp = data['time'] as Timestamp;
              final time = timeStamp.toDate();
              final formattedTime =
                  DateFormat('MMM d, yyyy hh:mm a').format(time);

              return ListTile(
                leading:
                    const Icon(Icons.local_pharmacy, color: Color(0xFF1A62B7)),
                title: Text(medicineName),
                subtitle: Text('Reminder at $formattedTime'),

                // 3) TRIPLE-DOT MENU to delete
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      // delete this doc from Firestore
                      await doc.reference.delete();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
