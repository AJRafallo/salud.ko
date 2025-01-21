import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';
import 'package:saludko/screens/widget/MedicineReminders/dose_list.dart';
import 'package:saludko/screens/widget/MedicineReminders/quantity_duration.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFDB0000)),
            onPressed: () => _onDeletePressed(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _notificationsEnabled,
                      thumbColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => Colors.white,
                      ),
                      trackColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                            ? const Color(0xFF1A62B7)
                            : const Color(0xFF49454F),
                      ),
                      thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                        (states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Icon(Icons.check,
                                color: Colors.black, size: 12);
                          } else {
                            return const Icon(Icons.close,
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
              const SizedBox(height: 12),
              // Doses List
              DosesListWidget(
                doses: _doses,
                onDosesChanged: (newDoses) {
                  setState(() {
                    _doses = newDoses;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Quantity + Duration
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
                decoration: _inputDecoration(
                  'Additional info: e.g. "Take with food".',
                ),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
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
      );

      // Update Firestore
      await docRef.update(updatedMed.toMap());

      Navigator.pop(context, updatedMed);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save medicine.')),
      );
    }
  }

  Future<void> _onDeletePressed(BuildContext context) async {
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
                // Cancel
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
                // Delete
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final docRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(_userId)
                          .collection('medicines')
                          .doc(widget.existingMedicine.id);

                      await docRef.delete();

                      // 1) close the alert dialog
                      Navigator.pop(ctx);

                      // 2) pop the EditMedicinePage
                      Navigator.pop(context);

                      // 3) pop the ViewMedicinePage
                      Navigator.pop(context);
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
}
