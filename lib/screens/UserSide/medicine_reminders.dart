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
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.fiber_manual_record,
                  color: Color(0xFFFFF27D), size: 12),
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
              const Icon(Icons.access_time, size: 14, color: Colors.white),
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
                style: TextStyle(fontSize: 14, color: Colors.white),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.black, size: 16),
                    Icon(Icons.add, color: Colors.black, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineList(BuildContext context, List<Medicine> medicines) {
    if (medicines.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDEEDFF),
          border: Border.all(color: const Color(0xFF9ECBFF)),
        ),
        child: const Text(
          'No medicines yet. Tap the + button to add one!',
          style: TextStyle(fontSize: 16, color: Colors.black54),
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
                    child: Icon(Icons.local_pharmacy, color: Color(0xFF1A62B7)),
                  ),
                ),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _smallCapsule(
                            text: _formatDuration(
                                med.durationType, med.durationValue),
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
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.black),
                    onPressed: () {
                      _showMedicineActionsBottomSheet(context, med);
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

  void _showMedicineActionsBottomSheet(BuildContext context, Medicine med) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.local_pharmacy, color: Colors.black),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      med.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              thickness: 0.5,
              color: Colors.black.withOpacity(0.2),
              height: 0,
            ),
            const SizedBox(height: 5),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text(
                'Edit',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToEditMedicine(context, med);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.black),
              title: const Text(
                'Delete',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteMedicineDialog(context, med);
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  void _showDeleteMedicineDialog(BuildContext context, Medicine med) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: const Center(
            child: Text(
              "Delete Medicine",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              Text(
                "Are you sure you want to delete this medicine?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF1A62B7)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF1A62B7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_userId)
                          .collection('medicines')
                          .doc(med.id)
                          .delete();
                      Navigator.pop(ctx); // close the dialog
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete medicine.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB0000),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _smallCapsule({
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
    );
  }

  void _navigateToAddMedicine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicinePage()),
    );
  }

  void _navigateToViewMedicine(BuildContext context, Medicine med) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewMedicinePage(medicine: med)),
    );
  }

  void _navigateToEditMedicine(BuildContext context, Medicine med) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EditMedicinePage(existingMedicine: med)),
    );
  }

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

    final nextIn =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

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

  String _formatDuration(String durationType, int durationValue) {
    switch (durationType) {
      case 'Everyday':
        return 'Everyday';
      case 'Every X Days':
        return 'Every $durationValue days';
      case 'Days':
        return '$durationValue Days';
      default:
        return durationType;
    }
  }
}
