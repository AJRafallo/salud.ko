import 'package:flutter/material.dart';

class AddSelfMonitoringDialog extends StatefulWidget {
  final Function(double, DateTime) onSave;
  final double? initialValue;
  final DateTime? initialDate;
  final String? dialogTitle;

  const AddSelfMonitoringDialog({
    super.key,
    required this.onSave,
    this.initialValue,
    this.initialDate,
    this.dialogTitle,
  });

  @override
  State<AddSelfMonitoringDialog> createState() =>
      _AddSelfMonitoringDialogState();
}

class _AddSelfMonitoringDialogState extends State<AddSelfMonitoringDialog> {
  late TextEditingController _glucoseController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _glucoseController = TextEditingController(
      text: widget.initialValue != null ? "${widget.initialValue}" : "",
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Column(
        children: [
          const Icon(Icons.bloodtype, size: 40, color: Color(0xFFb71a70)),
          const SizedBox(height: 10),
          Center(
            child: Text(
              widget.dialogTitle ?? 'Blood Glucose',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter your Blood Glucose (mg/dL)"),
            const SizedBox(height: 8),
            TextField(
              controller: _glucoseController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. 90",
                hintStyle: TextStyle(
                  color: Colors.grey, // Lighter hint text color
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Date of Measurement"),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${_selectedDate.month}/${_selectedDate.day}",
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
          onPressed: () {
            final textVal = _glucoseController.text.trim();
            if (textVal.isNotEmpty) {
              final val = double.tryParse(textVal);
              if (val != null) {
                widget.onSave(val, _selectedDate);
              }
            }
            Navigator.pop(context);
          },
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
