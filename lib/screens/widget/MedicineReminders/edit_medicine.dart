import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';

class AddOrEditMedicinePage extends StatefulWidget {
  final Medicine? existingMedicine;

  const AddOrEditMedicinePage({super.key, this.existingMedicine});

  @override
  State<AddOrEditMedicinePage> createState() => _AddOrEditMedicinePageState();
}

class _AddOrEditMedicinePageState extends State<AddOrEditMedicinePage> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;
  late TextEditingController _quantityController;

  List<String> _doses = [];
  String _quantityUnit = 'Tablets';
  String _durationType = 'Everyday';
  int _durationValue = 7;

  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  bool get isEdit => widget.existingMedicine != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final m = widget.existingMedicine!;
      _nameController = TextEditingController(text: m.name);
      _dosageController = TextEditingController(text: m.dosage.toString());
      _notesController = TextEditingController(text: m.notes);
      _quantityController = TextEditingController(text: m.quantity.toString());
      _quantityUnit = m.quantityUnit;
      _durationType = m.durationType;
      _durationValue = m.durationValue;
      _doses = List.from(m.doses);
    } else {
      _nameController = TextEditingController();
      _dosageController = TextEditingController();
      _notesController = TextEditingController();
      _quantityController = TextEditingController(text: '0');
      _doses = ['4:00 PM'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleWidget = isEdit
        ? const SizedBox()
        : const Text(
            'Add Medicine',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(child: titleWidget),
                ),
                if (isEdit)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Color(0xFFDB0000),
                    ),
                    onPressed: _onDeletePressed,
                  ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Medicine Name
              const Text(
                'Medicine Name',
                style: TextStyle(fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: _nameController,
                    onChanged: (val) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Medicine Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dosage
              const Text(
                'Medicine Dosage',
                style: TextStyle(fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _decrementDosage,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: _dosageController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        hintText: 'mg',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _incrementDosage,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Doses
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
                    const Center(
                      child: Text(
                        'Doses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < _doses.length; i++) ...[
                      Text(
                        'Dose ${i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _doses[i],
                                onChanged: (val) {
                                  setState(() {
                                    _doses[i] = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'e.g. 8:00 AM',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  final newTimeStr = _formatTimeOfDay(picked);
                                  setState(() {
                                    _doses[i] = newTimeStr;
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _doses.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Add new dose
                    Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _doses.add('4:00 PM');
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Dose'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quantity & Duration
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 140),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEEDFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 60),
                                    child: TextField(
                                      controller: _quantityController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 6),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _quantityUnit,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Right column (just a placeholder)
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A62B7),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Left',
                                    style: TextStyle(
                                      fontSize: 14,
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

                  const SizedBox(width: 10),

                  // Duration
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 140),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEEDFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButton<String>(
                            value: _durationType,
                            items: <String>['Everyday', 'Every X Days', 'Days']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _durationType = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Value: '),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (_durationValue > 1) {
                                    setState(() {
                                      _durationValue--;
                                    });
                                  }
                                },
                              ),
                              Text('$_durationValue'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _durationValue++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Notes
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                onChanged: (val) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Additional info: e.g. "Take with food".',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Save Changes
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
                  child: Text(
                    isEdit ? 'Save Changes' : 'Add Medicine',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Decrement dosage by 1, min 0
  void _decrementDosage() {
    final currentValue = double.tryParse(_dosageController.text.trim()) ?? 0.0;
    final newValue = (currentValue - 1).clamp(0, 9999999);
    setState(() {
      _dosageController.text = newValue.toStringAsFixed(0);
    });
  }

  // Increment dosage by 1
  void _incrementDosage() {
    final currentValue = double.tryParse(_dosageController.text.trim()) ?? 0.0;
    final newValue = currentValue + 1;
    setState(() {
      _dosageController.text = newValue.toStringAsFixed(0);
    });
  }

  // Save medicine in Firestore
  Future<void> _saveMedicine() async {
    final name = _nameController.text.trim();
    final dosage = double.tryParse(_dosageController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (!isEdit) {
      // CREATE
      final newDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('medicines')
          .doc();

      final newMed = Medicine(
        id: newDoc.id,
        name: name.isEmpty ? 'Unnamed' : name,
        dosage: dosage,
        dosageUnit: 'mg',
        doses: _doses,
        quantity: quantity,
        quantityUnit: _quantityUnit,
        durationType: _durationType,
        durationValue: _durationValue,
        notes: notes,
      );
      await newDoc.set(newMed.toMap());
      Navigator.pop(context, newMed);
    } else {
      // UPDATE
      final medId = widget.existingMedicine!.id;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('medicines')
          .doc(medId);

      final updatedMed = Medicine(
        id: medId,
        name: name.isEmpty ? 'Unnamed' : name,
        dosage: dosage,
        dosageUnit: 'mg',
        doses: _doses,
        quantity: quantity,
        quantityUnit: _quantityUnit,
        durationType: _durationType,
        durationValue: _durationValue,
        notes: notes,
      );
      await docRef.update(updatedMed.toMap());
      Navigator.pop(context, updatedMed);
    }
  }

  // Delete the existing medicine
  void _onDeletePressed() async {
    if (widget.existingMedicine == null) return;
    final medId = widget.existingMedicine!.id;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('medicines')
        .doc(medId);

    await docRef.delete();
    Navigator.pop(context, true);
  }

  // Helper for picking time and formatting
  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minuteStr = t.minute.toString().padLeft(2, '0');
    final amPm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minuteStr $amPm';
  }
}
