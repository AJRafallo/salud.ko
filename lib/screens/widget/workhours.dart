import 'package:flutter/material.dart';

class WorkHoursPicker extends StatefulWidget {
  final List<String> daysOfWeek; // List of days to display
  final Function(List<TimeOfDay?>, List<TimeOfDay?>) onSave; // Callback for saving times

  const WorkHoursPicker({
    super.key,
    required this.daysOfWeek,
    required this.onSave,
  });

  @override
  _WorkHoursPickerState createState() => _WorkHoursPickerState();
}

class _WorkHoursPickerState extends State<WorkHoursPicker> {
  List<TimeOfDay?> startTimes = List.filled(7, null); // Start times for each day
  List<TimeOfDay?> endTimes = List.filled(7, null); // End times for each day

  Future<void> _pickTime(int index, bool isStartTime) async {
    TimeOfDay initialTime = TimeOfDay.now();
    
    if (isStartTime && startTimes[index] != null) {
      initialTime = startTimes[index]!;
    } else if (!isStartTime && endTimes[index] != null) {
      initialTime = endTimes[index]!;
    }
    
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTimes[index] = picked;
        } else {
          endTimes[index] = picked;
        }
      });
    }
  }

  void saveWorkHours() {
    widget.onSave(startTimes, endTimes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < widget.daysOfWeek.length; index++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.daysOfWeek[index]),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickTime(index, true),
                    child: Text(startTimes[index]?.format(context) ?? 'Start'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _pickTime(index, false),
                    child: Text(endTimes[index]?.format(context) ?? 'End'),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: saveWorkHours,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
