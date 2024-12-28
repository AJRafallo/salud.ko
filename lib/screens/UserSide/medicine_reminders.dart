import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/view_medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/add_medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/edit_medicine.dart';

class MedicineRemindersPage extends StatefulWidget {
  const MedicineRemindersPage({super.key});

  @override
  State<MedicineRemindersPage> createState() => _MedicineRemindersPageState();
}

class _MedicineRemindersPageState extends State<MedicineRemindersPage> {
  // Current user
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_userId)
                .collection('medicines')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading medicines."));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              final medicines =
                  docs.map((doc) => Medicine.fromFirestore(doc)).toList();

              final nextMedicineData = _getEarliestNextDose(medicines);

              return Column(
                children: [
                  _buildUpcomingReminder(context, nextMedicineData),
                  const SizedBox(height: 8),
                  _buildMedicineHeader(context),
                  const SizedBox(height: 8),
                  _buildMedicineList(context, medicines),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Upcoming Medicine Reminder
  Widget _buildUpcomingReminder(
    BuildContext context,
    Map<String, dynamic>? nextData,
  ) {
    if (nextData == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2979D8), Color(0xFF39A0FF)],
            stops: [0.43, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Medicine Reminder',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Divider(color: Colors.white54, thickness: 1),
            SizedBox(height: 5),
            Text(
              'No upcoming medicine reminder.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    final med = nextData['medicine'] as Medicine;
    final nextIn = nextData['nextIn'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2979D8), Color(0xFF39A0FF)],
          stops: [0.43, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Medicine Reminder',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Divider(
            color: Colors.white54,
            thickness: 1,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                med.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${med.dosage.toStringAsFixed(0)} ${med.dosageUnit}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.fiber_manual_record,
                color: Color(0xFFFFF27D),
                size: 12,
              ),
              const SizedBox(width: 4),
              const Text(
                'NEXT IN ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.access_time,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                nextIn,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFFF27D),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'From Now',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Text(
            'Medicine',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _navigateToAddMedicine(context),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 16,
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Medicine List
  Widget _buildMedicineList(BuildContext context, List<Medicine> medicines) {
    if (medicines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No medicines yet. Tap the + button to add one!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: medicines.length,
      itemBuilder: (ctx, i) {
        final med = medicines[i];
        return InkWell(
          // Container is interactive, tapping opens view
          onTap: () => _navigateToViewMedicine(context, med),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDEEDFF),
              border: Border.all(color: const Color(0xFF9ECBFF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 80,
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                      Icons.local_pharmacy,
                      color: Color(0xFF1A62B7),
                    ),
                  ),
                ),
                // Medicine info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${med.dosage.toStringAsFixed(0)} ${med.dosageUnit}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display only the first dose + duration
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _smallCapsule(
                            text: med.durationType,
                            color: Colors.white,
                            textColor: Colors.black,
                          ),
                          if (med.doses.isNotEmpty)
                            _smallCapsule(
                              text: med.doses.first,
                              color: Colors.white,
                              textColor: Colors.black87,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Edit and Delete
                Center(
                  child: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        // Delete from Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_userId)
                            .collection('medicines')
                            .doc(med.id)
                            .delete();
                      } else if (value == 'edit') {
                        // Go to **EditMedicinePage**
                        _navigateToEditMedicine(context, med);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // capsule widget in medicine list
  Widget _smallCapsule({
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }

  // Add, View, Edit
  void _navigateToAddMedicine(BuildContext context) {
    // Navigate to your new "AddMedicinePage"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMedicinePage(),
      ),
    );
  }

  void _navigateToViewMedicine(BuildContext context, Medicine med) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewMedicinePage(medicine: med),
      ),
    );
  }

  void _navigateToEditMedicine(BuildContext context, Medicine med) {
    // Navigate to your new "EditMedicinePage"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMedicinePage(
          existingMedicine: med,
        ),
      ),
    );
  }

  // Get earliest next dose among all meds
  Map<String, dynamic>? _getEarliestNextDose(List<Medicine> medicines) {
    if (medicines.isEmpty) return null;

    final now = DateTime.now();
    DateTime? earliestTime;
    Medicine? earliestMed;

    for (final m in medicines) {
      for (final dose in m.doses) {
        var doseTime = _parseDoseToDateTime(dose);
        if (doseTime.isBefore(now)) {
          doseTime = doseTime.add(const Duration(days: 1));
        }
        if (earliestTime == null || doseTime.isBefore(earliestTime)) {
          earliestTime = doseTime;
          earliestMed = m;
        }
      }
    }

    if (earliestTime == null || earliestMed == null) return null;

    final diff = earliestTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    final nextIn = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';

    return {
      'medicine': earliestMed,
      'nextIn': nextIn,
    };
  }

  DateTime _parseDoseToDateTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(' ');
    if (parts.length != 2) return now;

    final hhmm = parts[0].split(':');
    if (hhmm.length != 2) return now;

    int hour = int.tryParse(hhmm[0]) ?? now.hour;
    int min = int.tryParse(hhmm[1]) ?? now.minute;
    final amPm = parts[1].toUpperCase();

    if (amPm == 'PM' && hour < 12) hour += 12;
    if (amPm == 'AM' && hour == 12) hour = 0;

    return DateTime(now.year, now.month, now.day, hour, min);
  }
}
