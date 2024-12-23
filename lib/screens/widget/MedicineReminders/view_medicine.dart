import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/cu_medicine.dart';

class ViewMedicinePage extends StatefulWidget {
  final Medicine medicine;

  const ViewMedicinePage({super.key, required this.medicine});

  @override
  State<ViewMedicinePage> createState() => _ViewMedicinePageState();
}

class _ViewMedicinePageState extends State<ViewMedicinePage> {
  late Medicine _currentMed;

  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentMed = widget.medicine;
  }

  @override
  Widget build(BuildContext context) {
    final med = _currentMed;

    final nextDoseStr = _getNextDoseForSingleMedicine(med);
    // "X times per day"
    final timesPerDay = med.doses.length;

    // How many days left is just the durationValue
    final daysLeft = med.durationValue;
    final durationString = _formatDuration(med.durationType, med.durationValue);

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicine Name',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 16,
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
                        Text(
                          'Turn on notifications?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Switch(
                              value: _notificationsEnabled,
                              onChanged: (val) {
                                setState(() {
                                  _notificationsEnabled = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicine Dosage',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${med.dosage.toStringAsFixed(0)} ${med.dosageUnit}',
                          style: const TextStyle(
                            fontSize: 16,
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
                        Text(
                          'Next Dose',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextDoseStr ?? '--',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A62B7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Doses
              const Text(
                'Dose',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$timesPerDay times per day',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),

              // For each dose, show a "field style"
              for (int i = 0; i < med.doses.length; i++) ...[
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Text(
                        '${_ordinal(i + 1)} Dose: ',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        med.doses[i],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A62B7),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 16),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  // Quantity
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${med.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A62B7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(':'),
                              const SizedBox(width: 8),
                              Text(
                                '${(med.quantity - 3).clamp(0, 999)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A62B7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${med.quantityUnit} Left',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Duration
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            durationString,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A62B7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$daysLeft DAYS LEFT',
                            style: const TextStyle(fontSize: 12),
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
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
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
                  onPressed: _navigateToEditMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A62B7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Edit Medication',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOrEditMedicinePage(existingMedicine: _currentMed),
      ),
    ).then((_) async {});
  }

  // Next dose for single med
  String? _getNextDoseForSingleMedicine(Medicine m) {
    if (m.doses.isEmpty) return null;
    final now = DateTime.now();
    DateTime? earliest;

    for (final doseStr in m.doses) {
      var dt = _parseDoseToDateTime(doseStr);
      if (dt.isBefore(now)) {
        dt = dt.add(const Duration(days: 1));
      }
      if (earliest == null || dt.isBefore(earliest)) {
        earliest = dt;
      }
    }

    if (earliest == null) return null;
    return DateFormat('h:mm a').format(earliest);
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

  // Format the duration type and value
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

  String _ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}
