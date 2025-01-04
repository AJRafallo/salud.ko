import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackFeed extends StatelessWidget {
  const FeedbackFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Feedback Feed',
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
            .collection('feedback') // Feedback collection
            .orderBy('timestamp', descending: true) // Sort by most recent feedback
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No feedbacks available.'));
          }

          final feedbacks = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "User Feedbacks",
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = feedbacks[index].data() as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                            child: ListTile(
                              title: Text(feedback['username'] ?? 'Anonymous User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold
                              ),),
                              subtitle: Text(feedback['feedback'] ?? 'No feedback available'),
                              trailing: Text(
                                _formatTimestamp(feedback['timestamp']),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper function to format timestamp
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final formattedTime = '${dateTime.hour}:${dateTime.minute}';
    return '$formattedDate at $formattedTime';
  }
}
