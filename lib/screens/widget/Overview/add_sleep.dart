import 'package:flutter/material.dart';

class AddSleepEntryDialog extends StatefulWidget {
  final Function(double hours, DateTime date) onSave;

  const AddSleepEntryDialog({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddSleepEntryDialog> createState() => _AddSleepEntryDialogState();
}

class _AddSleepEntryDialogState extends State<AddSleepEntryDialog> {
  final TextEditingController _hoursController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  /// Opens the date picker and sets [_selectedDate].
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      // Title with icon above + center alignment
      title: Column(
        children: [
          const Icon(
            Icons.bedtime,
            size: 40,
            color: Color(0xFF1A62B7),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Sleeping Hours',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // left alignment
          children: [
            // ---- Hours of Sleep ----
            const Text(
              'Enter your Hours of Sleep',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hoursController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Enter the amount of hours of sleep.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ---- Date of Measurement ----
            const Text(
              'Date of Measurement',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  // Show 'YYYY-MM-DD' style
                  '${_selectedDate.toLocal()}'.split(' ')[0],
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [
        // ---- Cancel Button ----
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: Color(0xFF1A62B7)),
            backgroundColor: Colors.white,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF1A62B7)),
          ),
        ),

        // ---- Save Button ----
        TextButton(
          onPressed: () {
            if (_hoursController.text.isNotEmpty) {
              final double? hours = double.tryParse(_hoursController.text);
              if (hours != null && hours > 0) {
                widget.onSave(hours, _selectedDate);
                Navigator.of(context).pop();
              }
            }
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF1A62B7),
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
