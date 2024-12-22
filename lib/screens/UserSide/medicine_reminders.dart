import 'dart:math';
import 'package:flutter/material.dart';

class Medicine {
  String id;
  String name;
  double dosage;
  String dosageUnit;
  List<String> doses;
  int quantity;
  String quantityUnit;
  String durationType;
  int durationValue;
  String notes;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.doses,
    required this.quantity,
    required this.quantityUnit,
    required this.durationType,
    required this.durationValue,
    required this.notes,
  });
}

class MedicineRemindersPage extends StatefulWidget {
  const MedicineRemindersPage({Key? key}) : super(key: key);

  @override
  State<MedicineRemindersPage> createState() => _MedicineRemindersPageState();
}

class _MedicineRemindersPageState extends State<MedicineRemindersPage> {
  final List<Medicine> _medicines = [
    Medicine(
      id: 'm1',
      name: 'Amoxicillin',
      dosage: 250,
      dosageUnit: 'mg',
      doses: ['8:00 AM', '4:00 PM'],
      quantity: 20,
      quantityUnit: 'Tablets',
      durationType: 'Everyday',
      durationValue: 7,
      notes: 'Take with food',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final nextMedicineData = _getEarliestNextDose();

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildUpcomingReminder(context, nextMedicineData),
              const SizedBox(height: 8),
              _buildMedicineHeader(context),
              const SizedBox(height: 8),
              _buildMedicineList(context),
            ],
          ),
        ),
      ),
    );
  }

  // Upcoming Medicine Reminder
  Widget _buildUpcomingReminder(
      BuildContext context, Map<String, dynamic>? nextData) {
    if (nextData == null) {
      // If no upcoming doses
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('No upcoming medicine reminder.'),
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
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.fiber_manual_record,
                color: Color(0xFFFFF27D),
                size: 12,
              ),
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
              const Icon(
                Icons.access_time,
                size: 14,
                color: Colors.white,
              ),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 16,
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Medicine List
  Widget _buildMedicineList(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final iconContainerWidth = 70.0;
    final iconContainerHeight = 80.0;
    final iconSize = 40.0;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medicines.length,
      itemBuilder: (ctx, i) {
        final med = _medicines[i];
        return InkWell(
          // Container is interactive, tapping opens edit
          onTap: () => _navigateToEditMedicine(context, med),
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
                  width: iconContainerWidth,
                  height: iconContainerHeight,
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                      Icons.local_pharmacy,
                      color: const Color(0xFF1A62B7),
                    ),
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
                      // Display only the first dose
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _smallCapsule(
                            text: med.durationType,
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
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _navigateToEditMedicine(context, med);
                      } else if (value == 'delete') {
                        setState(() {
                          _medicines.removeWhere((m) => m.id == med.id);
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
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

  Widget _smallCapsule({
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }

  void _navigateToAddMedicine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOrEditMedicinePage(
          onSave: (newMed) {
            setState(() {
              _medicines.add(newMed);
            });
          },
        ),
      ),
    );
  }

  void _navigateToEditMedicine(BuildContext context, Medicine med) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOrEditMedicinePage(
          existingMedicine: med,
          onSave: (updatedMed) {
            setState(() {
              final idx = _medicines.indexWhere((m) => m.id == med.id);
              if (idx != -1) {
                _medicines[idx] = updatedMed;
              }
            });
          },
        ),
      ),
    );
  }

  /// Finds the earliest next dose among all medicines
  Map<String, dynamic>? _getEarliestNextDose() {
    if (_medicines.isEmpty) return null;

    final now = DateTime.now();
    DateTime? earliestTime;
    Medicine? earliestMed;

    for (final m in _medicines) {
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

    final nextIn = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';

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

    // Convert hour based on AM/PM
    if (amPm == 'PM' && hour < 12) hour += 12;
    if (amPm == 'AM' && hour == 12) hour = 0;

    return DateTime(now.year, now.month, now.day, hour, min);
  }
}

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
  String _quantityUnit = 'Tablets';
  String _durationType = 'Everyday';
  int _durationValue = 7;

  @override
  void initState() {
    super.initState();
    if (widget.existingMedicine != null) {
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
    final isEdit = widget.existingMedicine != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Medicine Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Medicine Name',
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Medicine Dosage',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
              _buildDosesSection(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildQuantitySection()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDurationSection()),
                ],
              ),
              const SizedBox(height: 16),
              _buildNotesSection(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  child: Text(isEdit ? 'Save Changes' : 'Add Medicine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDosesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Doses (Time of Day)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < _doses.length; i++)
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
                    onChanged: (val) => _doses[i] = val,
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
        const Text(
          'Quantity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g. 20',
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
        const Text(
          'Duration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Additional info: e.g. "Take with food".',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void _saveMedicine() {
    final id = widget.existingMedicine?.id ?? _generateId();
    final name = _nameController.text.trim();
    final dosage = double.tryParse(_dosageController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    final newMed = Medicine(
      id: id,
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

    widget.onSave(newMed);
    Navigator.pop(context);
  }

  String _generateId() {
    return 'm${Random().nextInt(999999)}';
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minuteStr = t.minute.toString().padLeft(2, '0');
    final amPm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minuteStr $amPm';
  }
}
