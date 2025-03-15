import 'package:flutter/material.dart';

class BloodPressureWidget extends StatelessWidget {
  /// Each Map should look like: {
  ///   'id': string,
  ///   'systolic': double,
  ///   'diastolic': double,
  ///   'date': DateTime
  /// }
  final List<Map<String, dynamic>> data;
  final VoidCallback onAddEntry;
  final VoidCallback onReset;
  final VoidCallback onHide;
  final VoidCallback onEditEntries;

  const BloodPressureWidget({
    super.key,
    required this.data,
    required this.onAddEntry,
    required this.onReset,
    required this.onHide,
    required this.onEditEntries,
  });

  @override
  Widget build(BuildContext context) {
    // Sort data by date
    final sortedData = [...data];
    sortedData.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );

    // Prepare separate lists for the chart
    final List<Offset> systolicPoints = [];
    final List<Offset> diastolicPoints = [];

    for (var entry in sortedData) {
      final date = entry['date'] as DateTime;
      final systolic = entry['systolic'] as double;
      final diastolic = entry['diastolic'] as double;
      final xVal = date.millisecondsSinceEpoch.toDouble();

      systolicPoints.add(Offset(xVal, systolic));
      diastolicPoints.add(Offset(xVal, diastolic));
    }

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
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.monitor_heart_outlined, color: Color(0xFFB7561A)),
                  SizedBox(width: 8),
                  Text(
                    "Blood Pressure",
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
                  if (value == 'edit') {
                    onEditEntries();
                  } else if (value == 'reset') {
                    onReset();
                  } else if (value == 'hide') {
                    onHide();
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

          /// Chart area
          SizedBox(
            height: sortedData.isEmpty ? 80 : 200,
            child: sortedData.isEmpty
                ? const Center(
                    child: Text(
                      "No blood pressure data yet.",
                      style: TextStyle(fontSize: 13),
                    ),
                  )
                : _MultiLineChart(
                    systolicData: systolicPoints,
                    diastolicData: diastolicPoints,
                  ),
          ),
          const SizedBox(height: 16),

          /// List of textual entries: "120/80" and date
          if (sortedData.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortedData.map((entry) {
                  final date = entry['date'] as DateTime;
                  final systolic = entry['systolic'] as double;
                  final diastolic = entry['diastolic'] as double;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Text(
                          "${systolic.toStringAsFixed(0)}/${diastolic.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${date.month}/${date.day}",
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),

          /// "Add New Entry" button
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

class _MultiLineChart extends StatelessWidget {
  final List<Offset> systolicData;
  final List<Offset> diastolicData;

  const _MultiLineChart({
    required this.systolicData,
    required this.diastolicData,
  });

  @override
  Widget build(BuildContext context) {
    if (systolicData.isEmpty || diastolicData.isEmpty) {
      return const SizedBox();
    }

    // Combine to find overall min/max
    final allPoints = [...systolicData, ...diastolicData];
    allPoints.sort((a, b) => a.dx.compareTo(b.dx));

    double minX = allPoints.first.dx;
    double maxX = allPoints.last.dx;
    double minY = allPoints.first.dy;
    double maxY = allPoints.first.dy;

    for (final p in allPoints) {
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    // Avoid division by zero
    if (minX == maxX) {
      maxX = minX + 1;
    }
    if (minY == maxY) {
      maxY = minY + 1;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        final chartHeight = constraints.maxHeight;

        List<Offset> scalePoints(List<Offset> data) {
          return data.map((p) {
            final scaledX = (p.dx - minX) / (maxX - minX) * chartWidth;
            final scaledY =
                chartHeight - ((p.dy - minY) / (maxY - minY) * chartHeight);
            return Offset(scaledX, scaledY);
          }).toList();
        }

        final systolicPointsScaled = scalePoints(systolicData);
        final diastolicPointsScaled = scalePoints(diastolicData);

        return CustomPaint(
          painter: _MultiLineChartPainter(
            systolicPointsScaled,
            diastolicPointsScaled,
          ),
        );
      },
    );
  }
}

class _MultiLineChartPainter extends CustomPainter {
  final List<Offset> systolicPoints;
  final List<Offset> diastolicPoints;

  _MultiLineChartPainter(this.systolicPoints, this.diastolicPoints);

  @override
  void paint(Canvas canvas, Size size) {
    // Helper to draw line + dots
    void drawLineAndDots(List<Offset> points, Color color) {
      if (points.isEmpty) return;
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);

      // Draw dots
      final dotPaint = Paint()..color = color;
      for (final pt in points) {
        canvas.drawCircle(pt, 3, dotPaint);
      }
    }

    // Systolic in red, diastolic in blue
    drawLineAndDots(systolicPoints, Colors.red);
    drawLineAndDots(diastolicPoints, Colors.blue);
  }

  @override
  bool shouldRepaint(_MultiLineChartPainter oldDelegate) {
    return oldDelegate.systolicPoints != systolicPoints ||
        oldDelegate.diastolicPoints != diastolicPoints;
  }
}
