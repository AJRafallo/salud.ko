import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayWorkHoursWidget extends StatefulWidget {
  final String
      providerId; // Identifier for the provider to fetch work hours for

  const DisplayWorkHoursWidget({super.key, required this.providerId});

  @override
  _DisplayWorkHoursWidgetState createState() => _DisplayWorkHoursWidgetState();
}

class _DisplayWorkHoursWidgetState extends State<DisplayWorkHoursWidget> {
  Map<String, List<Map<String, String>>> workHours = {};
  bool isLoading = true;

  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  @override
  void initState() {
    super.initState();
    fetchWorkHours();
  }

  Future<void> fetchWorkHours() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(
              'healthcare_providers') // Adjust collection name as needed
          .doc(widget.providerId)
          .get();

      if (doc.exists && doc.data()?['workHours'] != null) {
        final fetchedWorkHours =
            Map<String, dynamic>.from(doc.data()!['workHours']);
        setState(() {
          workHours = fetchedWorkHours.map((key, value) {
            return MapEntry(
                key,
                List<Map<String, String>>.from(
                    value.map((e) => Map<String, String>.from(e))));
          });
          isLoading = false;
        });
      } else {
        setState(() {
          workHours = {}; // Default to empty work hours if none exist
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error fetching work hours: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            border: Border.all(
              color: Colors.grey, // Border color
              width: 1.0, // Border thickness
            ),
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: daysOfWeek.map((day) {
              final timeSlots =
                  workHours[day] ?? []; // Default to empty if no data
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15, // Larger size for the days
                      color: Colors.black87, // Slightly darker text color
                    ),
                  ),
                  if (timeSlots.isEmpty)
                    const Text(
                      "No work hours available.",
                      style: TextStyle(
                        fontSize: 12, // Slightly larger for better readability
                        color: Colors.grey,
                      ),
                    )
                  else
                    ...timeSlots.map((timeSlot) {
                      return Text(
                        "Start: ${timeSlot['start']} - End: ${timeSlot['end']}",
                        style: const TextStyle(
                          fontSize: 12, // Matches the "No work hours" text size
                          color: Colors.black54,
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 10), // Spacing between days
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
