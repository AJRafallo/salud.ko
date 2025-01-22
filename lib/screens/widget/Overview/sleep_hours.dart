import 'package:flutter/material.dart';

class SleepTrackingWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sleepData;
  final VoidCallback onAddEntry;
  final VoidCallback onReset;
  final VoidCallback onHide;

  const SleepTrackingWidget({
    Key? key,
    required this.sleepData,
    required this.onAddEntry,
    required this.onReset,
    required this.onHide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find max hours to scale bars
    double maxHours = 0.0;
    for (final entry in sleepData) {
      final hours = (entry['hours'] as double);
      if (hours > maxHours) {
        maxHours = hours;
      }
    }
    if (maxHours < 1) {
      maxHours = 1.0;
    }

    // If there is no data, we’ll show a smaller height container
    final double chartHeight = sleepData.isEmpty ? 80 : 200;

    return Container(
      padding: const EdgeInsets.all(20.0),
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
          // Top row: Sleep icon + title + triple-dot
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
              // Triple dot menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (String value) {
                  if (value == 'reset') {
                    onReset();
                  } else if (value == 'hide') {
                    onHide();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'reset',
                    child: Text('Reset'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'hide',
                    child: Text('Hide'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart
          SizedBox(
            height: chartHeight,
            child: sleepData.isEmpty
                ? const Center(
                    child: Text(
                      "No sleep data yet. Add a new entry.",
                      style: TextStyle(fontSize: 13),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: sleepData.map((data) {
                        final date = data['date'] as DateTime;
                        final hours = (data['hours'] as double);
                        final barHeight = (hours / maxHours) * 120.0;

                        // Format date as "MM/DD"
                        final String dateLabel = "${date.month}/${date.day}";

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
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
                                dateLabel,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Add New Entry Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAddEntry,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFF1A62B7),
                  width: 1.5,
                ),
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
