import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/dose_list.dart';
import 'package:saludko/screens/widget/MedicineReminders/quantity_duration.dart';
import 'package:saludko/screens/Services/localnotifications.dart';

class EditMedicinePage extends StatefulWidget {
  final Medicine existingMedicine;

  const EditMedicinePage({super.key, required this.existingMedicine});

  @override
  State<EditMedicinePage> createState() => _EditMedicinePageState();
}

class _EditMedicinePageState extends State<EditMedicinePage> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;

  bool _notificationsEnabled = false;
  List<String> _doses = [];
  int _quantity = 0;
  int _quantityLeft = 0;
  String _quantityUnit = 'Tablets';
  String _durationType = 'Everyday';
  int _durationValue = 7;

  // Round-the-clock
  bool _isRoundTheClock = false;
  int _roundInterval = 4;
  int _roundTimes = 3;
  String _roundStartTime = '8:00 AM';

  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMedicine;

    _nameController = TextEditingController(text: m.name);
    _dosageController = TextEditingController(text: m.dosage.toString());
    _notesController = TextEditingController(text: m.notes);

    _notificationsEnabled = m.notificationsEnabled;
    _doses = List.from(m.doses);
    _quantity = m.quantity;
    _quantityLeft = m.quantityLeft;
    _quantityUnit = m.quantityUnit;
    _durationType = m.durationType;
    _durationValue = m.durationValue;

    // Round-the-clock from the DB
    _isRoundTheClock = m.isRoundTheClock;
    _roundInterval = m.roundInterval;
    _roundTimes = m.roundTimes;
    _roundStartTime = m.roundStartTime;
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
    final med = widget.existingMedicine;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFDB0000)),
            onPressed: () => _onDeletePressed(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Medicine Name'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(color: Colors.black.withOpacity(0.8)),
                decoration: _inputDecoration('Enter Medicine Name'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Medicine Dosage'),
              const SizedBox(height: 8),
              TextField(
                controller: _dosageController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black.withOpacity(0.8)),
                decoration: _inputDecoration('mg'),
              ),
              const SizedBox(height: 12),

              // Notifications Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Turn on Notifications?',
                    style: TextStyle(color: Colors.black.withOpacity(0.7)),
                  ),
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
              const SizedBox(height: 12),

              // Doses
              DosesListWidget(
                doses: _doses,
                onDosesChanged: (newDoses) {
                  setState(() {
                    _doses = newDoses;
                  });
                },
                initialIsRoundTheClock: _isRoundTheClock,
                initialInterval: _roundInterval,
                initialTimes: _roundTimes,
                initialStartTime: _roundStartTime,
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

              _buildLabel('Notes'),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: Colors.black.withOpacity(0.8)),
                decoration:
                    _inputDecoration('Additional info: e.g. "Take with food".'),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A62B7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Save Changes',
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black.withOpacity(0.7),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Future<void> _saveMedicine() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('medicines')
          .doc(widget.existingMedicine.id);

      final updatedMed = Medicine(
        id: widget.existingMedicine.id,
        name: _nameController.text.trim(),
        dosage: double.tryParse(_dosageController.text.trim()) ?? 0.0,
        dosageUnit: 'mg',
        doses: _doses,
        quantity: _quantity,
        quantityLeft: _quantityLeft,
        quantityUnit: _quantityUnit,
        durationType: _durationType,
        durationValue: _durationValue,
        notes: _notesController.text.trim(),
        notificationsEnabled: _notificationsEnabled,

        // Round-the-clock fields
        isRoundTheClock: _isRoundTheClock,
        roundInterval: _roundInterval,
        roundTimes: _roundTimes,
        roundStartTime: _roundStartTime,
      );

      // Cancel existing local notifications
      for (int i = 0; i < widget.existingMedicine.doses.length; i++) {
        final oldId = widget.existingMedicine.id.hashCode + i;
        await LocalNotificationService.cancelNotification(oldId);
      }
      // Delete old notifications in Firestore
      final oldNotifs = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .where('notificationId',
              isGreaterThanOrEqualTo: widget.existingMedicine.id.hashCode)
          .where('notificationId',
              isLessThanOrEqualTo: widget.existingMedicine.id.hashCode + 100)
          .get();
      for (var doc in oldNotifs.docs) {
        await doc.reference.delete();
      }

      // Update the medicine doc in Firestore
      await docRef.update(updatedMed.toMap());

      // If notifications are enabled, schedule new ones
      if (_notificationsEnabled) {
        for (int i = 0; i < updatedMed.doses.length; i++) {
          final doseTimeStr = updatedMed.doses[i];
          // Parse "8:00 AM" -> DateTime
          DateTime scheduledTime = _parseDoseToDateTime(doseTimeStr);

          // ------------------------------------------------------------
          // FIX: If the parsed time is already in the past for 'today',
          //      push it to tomorrow so the plugin doesn't throw errors.
          final now = DateTime.now();
          if (scheduledTime.isBefore(now)) {
            scheduledTime = scheduledTime.add(const Duration(days: 1));
          }
          // ------------------------------------------------------------

          final notificationId = updatedMed.id.hashCode + i;

          try {
            await LocalNotificationService.scheduleNotification(
              id: notificationId,
              title: 'Time to take ${updatedMed.name}',
              body:
                  'Dosage: ${updatedMed.dosage.toStringAsFixed(0)} ${updatedMed.dosageUnit}',
              dateTime: scheduledTime,
            );
          } catch (e) {
            debugPrint('Error scheduling notification: $e');
          }

          // Add a document in notifications collection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .collection('notifications')
              .add({
            'medicineId': updatedMed.id,
            'medicineName': updatedMed.name,
            'status': 'unread',
            'time': scheduledTime,
            'createdAt': DateTime.now(),
            'notificationId': notificationId,
          });
        }
      }

      Navigator.pop(context, updatedMed);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save medicine.')),
      );
    }
  }

  void _onDeletePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        horizontal: 30, vertical: 10),
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
                      final docRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(_userId)
                          .collection('medicines')
                          .doc(widget.existingMedicine.id);

                      // Cancel existing notifications
                      for (int i = 0;
                          i < widget.existingMedicine.doses.length;
                          i++) {
                        final oldId = widget.existingMedicine.id.hashCode + i;
                        await LocalNotificationService.cancelNotification(
                            oldId);
                      }
                      // Delete the medicine doc
                      await docRef.delete();

                      // Delete any notifications in Firestore for this med
                      final oldNotifs = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_userId)
                          .collection('notifications')
                          .where(
                            'notificationId',
                            isGreaterThanOrEqualTo:
                                widget.existingMedicine.id.hashCode,
                          )
                          .where(
                            'notificationId',
                            isLessThanOrEqualTo:
                                widget.existingMedicine.id.hashCode + 100,
                          )
                          .get();
                      for (var doc in oldNotifs.docs) {
                        await doc.reference.delete();
                      }

                      Navigator.pop(ctx); // close the alert
                      Navigator.pop(context); // close Edit page
                      Navigator.pop(context); // close View page if needed
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to delete medicine.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB0000),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 10),
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

  // Convert "8:00 AM" -> DateTime (today)
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
