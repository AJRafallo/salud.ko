import 'package:flutter/material.dart';

class SleepTrackingWidget extends StatelessWidget {
  SleepTrackingWidget({super.key});

  // Dummy data for the bar chart
  final List<Map<String, dynamic>> sleepData = [
    {'day': 'Sun', 'hours': 7},
    {'day': 'Mon', 'hours': 6},
    {'day': 'Tue', 'hours': 5},
    {'day': 'Wed', 'hours': 8},
    {'day': 'Thu', 'hours': 6},
    {'day': 'Fri', 'hours': 7},
    {'day': 'Sat', 'hours': 9},
  ];

  @override
  Widget build(BuildContext context) {
    // 1) Calculate the maximum hours to scale bars
    double maxHours = 0.0;
    for (final entry in sleepData) {
      final hours = (entry['hours'] as num).toDouble();
      if (hours > maxHours) maxHours = hours;
    }
    if (maxHours < 1) maxHours = 1.0; // avoid division by zero

    return Container(
      padding: const EdgeInsets.all(20.0),
      // Light border + rounded corners + faint background
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        border: Border.all(
          color: const Color(0xFFDDDDDD),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: Sleep icon + "Sleep Hours" and triple-dot on the right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bedtime, color: Color(0xFF1A62B7)),
                  SizedBox(width: 8),
                  Text(
                    "Sleep Hours",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Tappable triple-dot (no functionality yet)
              InkWell(
                onTap: () {
                  // TODO: No functionality yet
                },
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart (fixed height to avoid overflow on small screens)
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sleepData.map((data) {
                final day = data['day'].toString();
                final hours = (data['hours'] as num).toDouble();
                final barHeight = (hours / maxHours) * 120;
                // out of 120 px for the bar area, leaving space for day/hour labels

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 14,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A62B7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hours.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: open a dialog/form for adding new sleep data
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF1A62B7), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Add New Entry",
                style: TextStyle(
                  color: Color(0xFF1A62B7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
