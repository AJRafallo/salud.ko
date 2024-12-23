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
  bool _notificationsEnabled = false;

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
      _notificationsEnabled = m.notificationsEnabled;
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
                  child: Center(
                    child: isEdit
                        ? const SizedBox()
                        : const Text(
                            'Add Medicine',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
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
              // Turn on notifications
              _buildNotificationsSwitch(),
              const SizedBox(height: 16),

              // Medicine Name
              _buildLabeledField('Medicine Name'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
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
              const SizedBox(height: 16),

              // Medicine Dosage
              _buildLabeledField('Medicine Dosage'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dosageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 250',
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
                  const SizedBox(width: 8),
                  const Text('mg'),
                ],
              ),
              const SizedBox(height: 16),

              // Doses
              _buildDosesSection(),
              const SizedBox(height: 16),

              // Quantity & Duration
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildQuantitySection()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDurationSection()),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              _buildLabeledField('Notes'),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
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

              // Save button
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

  Widget _buildNotificationsSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'Turn on notifications?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Switch(
          value: _notificationsEnabled,
          onChanged: (val) {
            setState(() {
              _notificationsEnabled = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLabeledField(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDosesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledField('Doses (Time of Day)'),
        const SizedBox(height: 8),
        for (int i = 0; i < _doses.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _doses[i],
                    onChanged: (val) => _doses[i] = val,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        TextButton.icon(
          onPressed: () {
            setState(() {
              _doses.add('4:00 PM');
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Dose'),
        )
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledField('Quantity'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 20',
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
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _quantityUnit,
              items: <String>['Tablets', 'Capsules Left', 'ml Left']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _quantityUnit = val;
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledField('Duration'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _durationType,
          items: <String>['Everyday', 'Every X Days', 'Days']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
          children: [
            const Text('Value:'),
            const SizedBox(width: 8),
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
    );
  }

  // Save or Delete
  Future<void> _saveMedicine() async {
    final name = _nameController.text.trim();
    final dosage = double.tryParse(_dosageController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (!isEdit) {
      // Create
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
        notificationsEnabled: _notificationsEnabled,
      );

      await newDoc.set(newMed.toMap());
    } else {
      // Update
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
        notificationsEnabled: _notificationsEnabled,
      );

      await docRef.update(updatedMed.toMap());
    }

    Navigator.pop(context);
  }

  void _onDeletePressed() async {
    final medId = widget.existingMedicine!.id;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('medicines')
        .doc(medId);

    await docRef.delete();
    Navigator.pop(context); // back out of the page after deleting
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minuteStr = t.minute.toString().padLeft(2, '0');
    final amPm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minuteStr $amPm';
  }
}
