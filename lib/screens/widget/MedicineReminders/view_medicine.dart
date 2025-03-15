import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:intl/intl.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/edit_medicine.dart';

class ViewMedicinePage extends StatelessWidget {
  final Medicine medicine;

  const ViewMedicinePage({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(medicine.id);

    return StreamBuilder<DocumentSnapshot>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Error loading medicine.')),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Medicine not found.')),
          );
        }

        final docData = snapshot.data!;
        final currentMed = Medicine.fromFirestore(docData);

        return _buildPage(context, currentMed);
      },
    );
  }

  Widget _buildPage(BuildContext context, Medicine med) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Notifications
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Medicine Name',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.6))),
                        const SizedBox(height: 8),
                        Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A62B7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifications',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.6))),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: med.notificationsEnabled,
                            onChanged: (val) {
                              // If you want to allow toggling from here:
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('medicines')
                                  .doc(med.id)
                                  .update({'notificationsEnabled': val});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Dosage
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Medicine Dosage',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.6))),
                        const SizedBox(height: 4),
                        Text(
                          '${med.dosage.toStringAsFixed(0)} ${med.dosageUnit}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A62B7)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // If round-the-clock is OFF, we might show "Next Dose"
                  // (But you can adapt as needed.)
                  Expanded(child: Container()),
                ],
              ),
              const SizedBox(height: 24),

              // If round-the-clock => show the relevant info, else show the dose list
              if (med.isRoundTheClock) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1EFC3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Round-the-Clock Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Start Time: ${med.roundStartTime}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Interval: ${med.roundInterval} hours',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Times per day: ${med.roundTimes}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ] else ...[
                // Normal dose listing
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1EFC3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Dose',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('${med.doses.length} times per day',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (int i = 0; i < med.doses.length; i++) ...[
                        Text('Dose ${i + 1}:',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Container(
                          constraints: const BoxConstraints(minHeight: 50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Row(
                            children: [
                              Text(
                                med.doses[i],
                                style: const TextStyle(fontSize: 14),
                              ),
                              const Spacer(),
                              const Icon(Icons.access_time,
                                  size: 16, color: Color(0xFF1A62B7)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Quantity/Duration row
              Row(
                children: [
                  // Quantity
                  Expanded(
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEEDFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${med.quantity}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A62B7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(med.quantityUnit,
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              const Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A62B7),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${med.quantityLeft}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A62B7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Left',
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Duration
                  Expanded(
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEEDFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Duration',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatDuration(
                                med.durationType, med.durationValue),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A62B7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${med.durationValue} DAYS LEFT',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFC1EFC3),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      med.notes.isEmpty ? 'No additional notes.' : med.notes,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToEditMedication(context, med),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A62B7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Edit Medication',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditMedication(BuildContext context, Medicine med) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EditMedicinePage(existingMedicine: med)),
    );
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
        return '$durationType ($durationValue)';
    }
  }
}
