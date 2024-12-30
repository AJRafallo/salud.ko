import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/edit_medicine.dart';

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
    _notificationsEnabled = _currentMed.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final med = _currentMed;

    final nextDoseStr = _getNextDoseForSingleMedicine(med);
    final timesPerDay = med.doses.length;
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          'Notifications',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _notificationsEnabled,
                            thumbColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) => Colors.white,
                            ),
                            trackColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) =>
                                  states.contains(MaterialState.selected)
                                      ? const Color(0xFF1A62B7)
                                      : const Color(0xFF49454F),
                            ),
                            thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                              (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return const Icon(Icons.check,
                                      color: Colors.black, size: 12);
                                } else {
                                  return Icon(Icons.close,
                                      color: Colors.grey, size: 12);
                                }
                              },
                            ),
                            onChanged: (val) {
                              setState(() {
                                _notificationsEnabled = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dosage & Next Dose
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

                  // Next Dose
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
              const SizedBox(height: 24),

              // Dose container
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
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Dose',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$timesPerDay times per day',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < med.doses.length; i++) ...[
                      Text('${_ordinal(i + 1)} Dose:',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              med.doses[i],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A62B7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.access_time, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quantity & Duration
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
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // total quantity
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
                                  Text(
                                    med.quantityUnit,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              // The colon
                              const Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // quantity left
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
                                  const Text(
                                    'Left',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
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
                          Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            durationString,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A62B7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$daysLeft DAYS LEFT',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes container
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Edit Medication button
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

  void _navigateToEditMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMedicinePage(existingMedicine: _currentMed),
      ),
    ).then((_) {
      // Refresh if needed
    });
  }

  // Next dose
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
    // Same logic as in common_functions.dart, but included inline for demonstration
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
