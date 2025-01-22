import 'package:flutter/material.dart';

class AddBloodPressureDialog extends StatefulWidget {
  /// Returns (systolic, diastolic, date)
  final Function(double, double, DateTime) onSave;

  final double? initialSystolic;
  final double? initialDiastolic;
  final DateTime? initialDate;
  final String? dialogTitle;

  const AddBloodPressureDialog({
    super.key,
    required this.onSave,
    this.initialSystolic,
    this.initialDiastolic,
    this.initialDate,
    this.dialogTitle,
  });

  @override
  State<AddBloodPressureDialog> createState() => _AddBloodPressureDialogState();
}

class _AddBloodPressureDialogState extends State<AddBloodPressureDialog> {
  late TextEditingController _systolicController;
  late TextEditingController _diastolicController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    // Pre-fill the controllers if available:
    _systolicController = TextEditingController(
      text: widget.initialSystolic != null
          ? widget.initialSystolic!.toStringAsFixed(0)
          : "",
    );
    _diastolicController = TextEditingController(
      text: widget.initialDiastolic != null
          ? widget.initialDiastolic!.toStringAsFixed(0)
          : "",
    );

    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveEntry() {
    final systolicText = _systolicController.text.trim();
    final diastolicText = _diastolicController.text.trim();

    if (systolicText.isEmpty || diastolicText.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final systolicVal = double.tryParse(systolicText);
    final diastolicVal = double.tryParse(diastolicText);

    if (systolicVal != null && diastolicVal != null) {
      widget.onSave(systolicVal, diastolicVal, _selectedDate);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Column(
        children: [
          const Icon(Icons.monitor_heart_outlined,
              size: 40, color: Color(0xFFB7561A)),
          const SizedBox(height: 10),
          Center(
            child: Text(
              widget.dialogTitle ?? 'Blood Pressure',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter your Blood Pressure"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _systolicController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.black87),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Systolic",
                      labelStyle: TextStyle(color: Colors.black54),
                      hintText: "e.g. 120",
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _diastolicController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.black87),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Diastolic",
                      labelStyle: TextStyle(color: Colors.black54),
                      hintText: "e.g. 80",
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Date of Measurement"),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            side: const BorderSide(color: Color(0xFF1A62B7)),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Color(0xFF1A62B7)),
          ),
        ),
        TextButton(
          onPressed: _saveEntry,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF1A62B7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Save",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
