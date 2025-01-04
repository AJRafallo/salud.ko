import 'package:flutter/material.dart';

class WorkHoursWidget extends StatefulWidget {
  final Map<String, List<Map<String, String>>> workHours;
  final Function(Map<String, List<Map<String, String>>>) onSave;

  const WorkHoursWidget(
      {super.key, required this.workHours, required this.onSave});

  @override
  _WorkHoursWidgetState createState() => _WorkHoursWidgetState();
}

class _WorkHoursWidgetState extends State<WorkHoursWidget> {
  late Map<String, List<Map<String, String>>> workHours;

  @override
  void initState() {
    super.initState();
    // If no work hours are provided, set a default value.
    workHours = widget.workHours.isEmpty
        ? {
            'Monday': [
              {'start': '09:00 AM', 'end': '05:00 PM'}
            ],
            'Tuesday': [
              {'start': '09:00 AM', 'end': '05:00 PM'}
            ],
            'Wednesday': [
              {'start': '09:00 AM', 'end': '05:00 PM'}
            ],
            'Thursday': [
              {'start': '09:00 AM', 'end': '05:00 PM'}
            ],
            'Friday': [
              {'start': '09:00 AM', 'end': '05:00 PM'}
            ],
            'Saturday': [
              {'start': '09:00 AM', 'end': '05:00 PM'}
            ],
            'Sunday': [
              {'start': '09:00 AM', 'end': '05:00 PM'}
            ],
          }
        : widget.workHours;
  }

  void addTimeSlot(String day) {
    setState(() {
      workHours[day]!.add({"start": "09:00 AM", "end": "05:00 PM"});
    });
  }

  void removeTimeSlot(String day, int index) {
    setState(() {
      workHours[day]!.removeAt(index);
    });
  }

  Future<void> selectTime(
      BuildContext context, String day, int index, String key) async {
    final TimeOfDay initialTime =
        TimeOfDay(hour: 9, minute: 0); // Default to 9:00 AM
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        workHours[day]![index][key] = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(0), // Padding around the container
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey,
              width: 1), // Border around the entire container
          borderRadius:
              BorderRadius.circular(15), // Rounded corners for the container
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            ...workHours.keys.map((day) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ExpansionTile(
                  title: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(
                          0.0), // Increased padding inside the card
                      child: Column(
                        children: [
                          ...List.generate(workHours[day]!.length, (index) {
                            return ListTile(
                              title: Column(
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.access_time),
                                                onPressed: () => selectTime(
                                                    context,
                                                    day,
                                                    index,
                                                    'start'),
                                              ),
                                              Text(
                                                  "Start: ${workHours[day]![index]['start']}"),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.access_time),
                                                onPressed: () => selectTime(
                                                    context, day, index, 'end'),
                                              ),
                                              Text(
                                                  "End: ${workHours[day]![index]['end']}"),
                                            ],
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle),
                                        onPressed: () =>
                                            removeTimeSlot(day, index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          ElevatedButton(
                            onPressed: () => addTimeSlot(day),
                            child: const Text("Add time slot"),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                widget.onSave(
                    workHours); // Pass the updated work hours back to the parent widget
              },
              child: const Text("Save Work Hours"),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
