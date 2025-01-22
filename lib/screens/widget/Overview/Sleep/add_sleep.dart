import 'package:flutter/material.dart';

class AddSleepEntryDialog extends StatefulWidget {
  final Function(double hours, DateTime date) onSave;
  final double? initialHours;
  final DateTime? initialDate;
  final String? dialogTitle;

  const AddSleepEntryDialog({
    super.key,
    required this.onSave,
    this.initialHours,
    this.initialDate,
    this.dialogTitle,
  });

  @override
  State<AddSleepEntryDialog> createState() => _AddSleepEntryDialogState();
}

class _AddSleepEntryDialogState extends State<AddSleepEntryDialog> {
  late TextEditingController _hoursController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(
      text: widget.initialHours != null ? "${widget.initialHours}" : "",
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
          const Icon(Icons.bedtime, size: 40, color: Color(0xFF1A62B7)),
          const SizedBox(height: 10),
          Center(
            child: Text(
              widget.dialogTitle ?? 'Sleeping Hours',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter your Hours of Sleep"),
            const SizedBox(height: 8),
            TextField(
              controller: _hoursController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: "e.g. 7.5",
                hintStyle: TextStyle(
                  color: Colors.black38,
                ),
                border: OutlineInputBorder(),
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
            final text = _hoursController.text.trim();
            if (text.isNotEmpty) {
              final val = double.tryParse(text);
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
