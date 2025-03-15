import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/dose_list.dart';
import 'package:saludko/screens/widget/MedicineReminders/quantity_duration.dart';
import 'package:saludko/screens/Services/localnotifications.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  // Basic fields
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;

  // Doses
  List<String> _doses = [];

  // Round-the-clock fields
  bool _isRoundTheClock = false;
  int _roundInterval = 4;
  int _roundTimes = 3;
  String _roundStartTime = '8:00 AM';

  // Quantity & Duration
  int _quantity = 0;
  int _quantityLeft = 0;
  String _quantityUnit = 'Tablets';
  String _durationType = 'Everyday';
  int _durationValue = 7;

  bool _notificationsEnabled = false;

  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _notesController = TextEditingController();

    _doses = ['8:00 AM']; // default
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildSectionTitle('Medicine Name'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'Enter Medicine Name'),
              const SizedBox(height: 16),

              _buildSectionTitle('Medicine Dosage'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _decrementDosage,
                    child: const Icon(Icons.chevron_left,
                        size: 28, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  _buildSmallTextField(_dosageController, 'mg',
                      isCentered: true),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _incrementDosage,
                    child: const Icon(Icons.chevron_right,
                        size: 28, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // DosesListWidget with new props
              DosesListWidget(
                doses: _doses,
                onDosesChanged: (newDoses) {
                  setState(() {
                    _doses = newDoses;
                  });
                },

                // Round-the-clock initial data
                initialIsRoundTheClock: _isRoundTheClock,
                initialInterval: _roundInterval,
                initialTimes: _roundTimes,
                initialStartTime: _roundStartTime,

                // Callbacks
                onRoundTheClockChanged: (val) {
                  setState(() {
                    _isRoundTheClock = val;
                  });
                },
                onIntervalChanged: (val) {
                  setState(() {
                    _roundInterval = val;
                  });
                },
                onTimesChanged: (val) {
                  setState(() {
                    _roundTimes = val;
                  });
                },
                onStartTimeChanged: (val) {
                  setState(() {
                    _roundStartTime = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Quantity & Duration
              QuantityDurationWidget(
                quantity: _quantity,
                quantityLeft: _quantityLeft,
                quantityUnit: _quantityUnit,
                durationType: _durationType,
                durationValue: _durationValue,
                onQuantityChanged: (val) => setState(() => _quantity = val),
                onQuantityLeftChanged: (val) =>
                    setState(() => _quantityLeft = val),
                onQuantityUnitChanged: (val) =>
                    setState(() => _quantityUnit = val),
                onDurationTypeChanged: (val) =>
                    setState(() => _durationType = val),
                onDurationValueChanged: (val) =>
                    setState(() => _durationValue = val),
              ),
              const SizedBox(height: 16),

              // Notes
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: Colors.black.withOpacity(0.8)),
                decoration: InputDecoration(
                  hintText: 'Additional info: e.g. "Take with food".',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Notifications toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enable Notifications?',
                      style: TextStyle(fontSize: 16)),
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
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A62B7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add Medicine',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _incrementDosage() {
    final currentDosage = double.tryParse(_dosageController.text.trim()) ?? 0.0;
    _dosageController.text = (currentDosage + 1).toString();
  }

  void _decrementDosage() {
    final currentDosage = double.tryParse(_dosageController.text.trim()) ?? 0.0;
    if (currentDosage > 0) {
      _dosageController.text = (currentDosage - 1).toString();
    }
  }

  Widget _buildSectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController controller, String hint,
      {bool isCentered = false}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 80),
      child: TextField(
        controller: controller,
        textAlign: isCentered ? TextAlign.center : TextAlign.start,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }

  Future<void> _saveMedicine() async {
    final name = _nameController.text.trim();
    final dosage = double.tryParse(_dosageController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('medicines')
        .doc();

    final newMed = Medicine(
      id: docRef.id,
      name: name.isEmpty ? 'Unnamed' : name,
      dosage: dosage,
      dosageUnit: 'mg',
      doses: _doses,
      quantity: _quantity,
      quantityLeft: _quantityLeft,
      quantityUnit: _quantityUnit,
      durationType: _durationType,
      durationValue: _durationValue,
      notes: notes,
      notificationsEnabled: _notificationsEnabled,

      // NEW fields
      isRoundTheClock: _isRoundTheClock,
      roundInterval: _roundInterval,
      roundTimes: _roundTimes,
      roundStartTime: _roundStartTime,
    );

    // Save
    await docRef.set(newMed.toMap());

    // If notifications are enabled, schedule them for each dose in _doses
    if (_notificationsEnabled) {
      for (int i = 0; i < _doses.length; i++) {
        final doseTimeStr = _doses[i];
        final scheduledTime = _parseDoseToDateTime(doseTimeStr);
        final notificationId = docRef.id.hashCode + i;

        try {
          await LocalNotificationService.scheduleNotification(
            id: notificationId,
            title: 'Time to take ${newMed.name}',
            body:
                'Dosage: ${newMed.dosage.toStringAsFixed(0)} ${newMed.dosageUnit}',
            dateTime: scheduledTime,
          );
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('notifications')
            .add({
          'medicineId': newMed.id,
          'medicineName': newMed.name,
          'status': 'unread',
          'time': scheduledTime,
          'createdAt': DateTime.now(),
          'notificationId': notificationId,
        });
      }
    }

    Navigator.pop(context);
  }

  /// Convert "8:00 AM" -> DateTime (today)
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
