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
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A62B7),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Only show notifications if their 'time' <= now (i.e. it's due or past).
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('time',
                isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data?.docs ?? [];
          if (allDocs.isEmpty) {
            return const Center(child: Text('No notifications available.'));
          }

          // Group them by date string
          final grouped = _groupByDate(allDocs);

          return ListView.builder(
            itemCount: grouped.length,
            itemBuilder: (ctx, index) {
              final entry = grouped.entries.elementAt(index);
              final dateLabel = entry.key;
              final docsForDate = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date label
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Notifications for that date
                  for (final doc in docsForDate) ...[
                    _buildNotificationItem(context, doc),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Builds the UI for a single notification item
  Widget _buildNotificationItem(
      BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final String medicineId = data['medicineId'] ?? ''; // might be empty
    final String medicineName = data['medicineName'] ?? 'Unknown';

    // We expect 'time' to be a Timestamp
    final Timestamp timestamp =
        data['time'] is Timestamp ? data['time'] as Timestamp : Timestamp.now();
    final DateTime doseTime = timestamp.toDate();

    final String formattedTime =
        DateFormat('h:mm a - MMM d, yyyy').format(doseTime);

    // status could be "unread", "taken", "skipped", etc.
    final String status = data['status'] ?? 'unread';

    // Slight background color if unread
    final containerColor =
        (status == 'unread') ? const Color(0xFFDEEDFF) : Colors.white;

    return Container(
      color: containerColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: 2),

            // Middle text (Medication Reminder, "Time to take", etc.)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medication Reminder',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Time to take $medicineName.',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  if (status == 'taken')
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Taken.',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 14),
                      ),
                    )
                  else if (status == 'skipped')
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Skipped.',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Right side: Centered Taken button and triple dot menu
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (status == 'unread')
                  Align(
                    alignment: Alignment.center,
                    child: _takenButton(doc, medicineId, doseTime),
                  ),
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.center,
                  child: _threeDotMenu(doc, medicineId, doseTime),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The "Taken" button
  Widget _takenButton(
    QueryDocumentSnapshot doc,
    String medicineId,
    DateTime doseTime,
  ) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return ElevatedButton(
      onPressed: () async {
        try {
          // Mark as taken
          await doc.reference.update({'status': 'taken'});

          // Decrement the quantityLeft of the medicine
          if (medicineId.isNotEmpty && medicineId != 'Unknown') {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('medicines')
                .doc(medicineId)
                .update({
              'quantityLeft': FieldValue.increment(-1), // Decrease the quantity
            });

            // Check if we need to decrement the day's duration
            await _maybeDecrementDay(userId, medicineId, doseTime);
          }
        } catch (e) {
          debugPrint('Error in takenButton: $e');
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: const Color(0xFF1A62B7),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: const Text(
        'Taken',
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }

  Widget _skippedButton(
    QueryDocumentSnapshot doc,
    String medicineId,
    DateTime doseTime,
  ) {
    return ElevatedButton(
      onPressed: () async {
        try {
          // Mark as skipped
          await doc.reference.update({'status': 'skipped'});
        } catch (e) {
          debugPrint('Error in skippedButton: $e');
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF1A62B7)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: const Text(
        'Skipped',
        style: TextStyle(fontSize: 12, color: Color(0xFF1A62B7)),
      ),
    );
  }

  /// Popup menu for deleting this notification
  Widget _threeDotMenu(
    QueryDocumentSnapshot doc,
    String medicineId,
    DateTime doseTime,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'delete') {
          await doc.reference.delete();
        } else if (value == 'skipped') {
          try {
            // Mark as skipped
            await doc.reference.update({'status': 'skipped'});

            // Handle day decrement logic if needed
            if (medicineId.isNotEmpty && medicineId != 'Unknown') {
              await _maybeDecrementDay(
                FirebaseAuth.instance.currentUser!.uid,
                medicineId,
                doseTime,
              );
            }
          } catch (e) {
            debugPrint('Error marking skipped: $e');
          }
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
        const PopupMenuItem<String>(
          value: 'skipped',
          child: Text('Mark as Skipped'),
        ),
      ],
    );
  }

  /// Check if all notifications (for this medicine, on this date) are done => decrement duration.
  Future<void> _maybeDecrementDay(
      String userId, String medicineId, DateTime doseTime) async {
    try {
      final startOfDay =
          DateTime(doseTime.year, doseTime.month, doseTime.day, 0, 0, 0);
      final endOfDay =
          DateTime(doseTime.year, doseTime.month, doseTime.day, 23, 59, 59);

      final querySnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('medicineId', isEqualTo: medicineId)
          .where('time', isGreaterThanOrEqualTo: startOfDay)
          .where('time', isLessThanOrEqualTo: endOfDay)
          .get();

      if (querySnap.docs.isEmpty) return;

      bool allDone = true;
      for (final n in querySnap.docs) {
        final nData = n.data();
        final s = nData['status'] ?? 'unread';
        if (s == 'unread') {
          allDone = false;
          break;
        }
      }

      if (allDone) {
        // Decrement the day
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('medicines')
            .doc(medicineId)
            .update({
          'durationValue': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      debugPrint('Error in _maybeDecrementDay: $e');
    }
  }

  /// Group docs by "Today", "Yesterday", or "Month d, yyyy"
  Map<String, List<QueryDocumentSnapshot>> _groupByDate(
      List<QueryDocumentSnapshot> docs) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['time'] is! Timestamp) continue; // skip invalid
      final docTime = (data['time'] as Timestamp).toDate();

      final dateLabel = _getDateLabel(docTime);
      grouped.putIfAbsent(dateLabel, () => []).add(doc);
    }

    return grouped;
  }

  String _getDateLabel(DateTime docTime) {
    final now = DateTime.now();
    if (_isSameDay(docTime, now)) return 'Today';
    if (_isSameDay(docTime, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('MMMM d, yyyy').format(docTime);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
