import 'package:flutter/material.dart';

class SleepTrackingWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sleepData;
  final VoidCallback onAddEntry;
  final VoidCallback onReset;
  final VoidCallback onHide;
  final VoidCallback onEditEntries;

  const SleepTrackingWidget({
    super.key,
    required this.sleepData,
    required this.onAddEntry,
    required this.onReset,
    required this.onHide,
    required this.onEditEntries,
  });

  @override
  Widget build(BuildContext context) {
    final sortedData = [...sleepData];
    sortedData.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );

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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (String value) {
                  if (value == 'reset') {
                    onReset();
                  } else if (value == 'hide') {
                    onHide();
                  } else if (value == 'edit') {
                    onEditEntries();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit Entry'),
                  ),
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
            height: sortedData.isEmpty ? 80 : 200,
            child: sortedData.isEmpty
                ? const Center(
                    child: Text(
                      "No sleep data yet. Add a new entry.",
                      style: TextStyle(fontSize: 13),
                    ),
                  )
                : _SleepBarChart(sortedData),
          ),
          const SizedBox(height: 16),

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

class _SleepBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _SleepBarChart(this.data);

  @override
  Widget build(BuildContext context) {
    double maxHours = 0;
    for (final entry in data) {
      final hours = (entry['hours'] as double);
      if (hours > maxHours) maxHours = hours;
    }
    if (maxHours < 1) maxHours = 1.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((entry) {
          final dt = entry['date'] as DateTime;
          final hours = (entry['hours'] as double);
          final barFactor = hours / maxHours;
          final barHeight = barFactor * 120;

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
                const SizedBox(height: 6),
                Text(
                  hours.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "${dt.month}/${dt.day}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
