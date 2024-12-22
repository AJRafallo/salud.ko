import 'dart:math';
import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/MedicineReminders/medicine.dart';

class AddOrEditMedicinePage extends StatefulWidget {
  final Medicine? existingMedicine;
  final void Function(Medicine) onSave;

  const AddOrEditMedicinePage({
    Key? key,
    this.existingMedicine,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddOrEditMedicinePage> createState() => _AddOrEditMedicinePageState();
}

class _AddOrEditMedicinePageState extends State<AddOrEditMedicinePage> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;
  late TextEditingController _quantityController;

  List<String> _doses = [];
  String _quantityUnit = 'Tablets Left';
  String _durationType = 'Everyday';
  int _durationValue = 7;

  @override
  void initState() {
    super.initState();
    final med = widget.existingMedicine;
    if (med != null) {
      _nameController = TextEditingController(text: med.name);
      _dosageController = TextEditingController(text: med.dosage.toString());
      _notesController = TextEditingController(text: med.notes);
      _doses = List.from(med.doses);
      _quantityController =
          TextEditingController(text: med.quantity.toString());
      _quantityUnit = med.quantityUnit;
      _durationType = med.durationType;
      _durationValue = med.durationValue;
    } else {
      _nameController = TextEditingController();
      _dosageController = TextEditingController();
      _notesController = TextEditingController();
      _quantityController = TextEditingController(text: '0');
      _doses = ['4:00 PM'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMedicine != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _fieldTitle('Medicine Name'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter Medicine Name',
              ),
            ),
            const SizedBox(height: 16),
            _fieldTitle('Medicine Dosage'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dosageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 250',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('mg'),
              ],
            ),
            const SizedBox(height: 16),
            _fieldTitle('Doses (Time of Day)'),
            _buildDosesSection(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildQuantitySection()),
                const SizedBox(width: 16),
                Expanded(child: _buildDurationSection()),
              ],
            ),
            const SizedBox(height: 16),
            _fieldTitle('Notes'),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Take with food',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save Changes' : 'Add Medicine'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDosesSection() {
    return Column(
      children: [
        for (int i = 0; i < _doses.length; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _doses[i],
                    onChanged: (val) {
                      _doses[i] = val;
                    },
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
                      setState(() {
                        _doses[i] = _formatTimeOfDay(picked);
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
        TextButton.icon(
          onPressed: () {
            setState(() {
              _doses.add('4:00 PM');
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Dose'),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldTitle('Quantity'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _quantityUnit,
              items: ['Tablets Left', 'Capsules Left', 'ml Left']
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
        _fieldTitle('Duration'),
        DropdownButton<String>(
          value: _durationType,
          items: ['Everyday', 'Every X Days', 'Days']
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _durationType = val;
              });
            }
          },
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (_durationValue > 1) _durationValue--;
                });
              },
            ),
            Text(_durationValue.toString()),
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

  void _save() {
    final med = widget.existingMedicine;
    final newId = med?.id ?? 'm${Random().nextInt(999999)}';
    final newName = _nameController.text.trim().isEmpty
        ? 'Unnamed'
        : _nameController.text.trim();
    final newDosage = double.tryParse(_dosageController.text.trim()) ?? 0;
    final newNotes = _notesController.text.trim();
    final newQuantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    final newMedicine = Medicine(
      id: newId,
      name: newName,
      dosage: newDosage,
      dosageUnit: 'mg',
      doses: _doses,
      quantity: newQuantity,
      quantityUnit: _quantityUnit,
      durationType: _durationType,
      durationValue: _durationValue,
      notes: newNotes,
    );

    widget.onSave(newMedicine);
    Navigator.pop(context);
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final amPm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $amPm';
  }
}
