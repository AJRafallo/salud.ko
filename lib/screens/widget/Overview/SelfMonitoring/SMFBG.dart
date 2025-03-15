import 'package:flutter/material.dart';

class SelfMonitoringWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final VoidCallback onAddEntry;
  final VoidCallback onReset;
  final VoidCallback onHide;
  final VoidCallback onEditEntries;

  const SelfMonitoringWidget({
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
                  Icon(Icons.bloodtype, color: Color(0xFFb71a70)),
                  SizedBox(width: 8),
                  Text(
                    "Blood Glucose",
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

          // Chart area
          SizedBox(
            height: sortedData.isEmpty ? 80 : 200,
            child: sortedData.isEmpty
                ? const Center(
                    child: Text(
                      "No blood glucose data yet.",
                      style: TextStyle(fontSize: 13),
                    ),
                  )
                : _ColoredLineChart(
                    data: sortedData.map((m) {
                      return Offset(
                        (m['date'] as DateTime).millisecondsSinceEpoch * 1.0,
                        (m['value'] as double),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),

          if (sortedData.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortedData.map((entry) {
                  final date = entry['date'] as DateTime;
                  final value = entry['value'] as double;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Text(
                          value.toString(),
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

// Chart with red if rising, blue if falling
class _ColoredLineChart extends StatelessWidget {
  final List<Offset> data;

  const _ColoredLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final sorted = [...data];
    sorted.sort((a, b) => a.dx.compareTo(b.dx));
    final double minX = sorted.first.dx;
    final double maxX = sorted.last.dx == minX ? (minX + 1) : sorted.last.dx;

    double minY = sorted.first.dy;
    double maxY = sorted.first.dy;
    for (final p in sorted) {
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    if (minY == maxY) {
      maxY = minY + 1;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        final chartHeight = constraints.maxHeight;

        final canvasPoints = sorted.map((p) {
          final scaledX = (p.dx - minX) / (maxX - minX) * chartWidth;
          final scaledY =
              chartHeight - ((p.dy - minY) / (maxY - minY) * chartHeight);
          return Offset(scaledX, scaledY);
        }).toList();

        return CustomPaint(
          painter: _ColoredLineChartPainter(points: canvasPoints),
        );
      },
    );
  }
}

class _ColoredLineChartPainter extends CustomPainter {
  final List<Offset> points;

  _ColoredLineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    if (points.length == 1) {
      final singlePaint = Paint()..color = Colors.red;
      canvas.drawCircle(points.first, 3, singlePaint);
      return;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      final bool isRising = next.dy < current.dy;
      final color = isRising ? Colors.red : Colors.blue;

      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(current.dx, current.dy);
      path.lineTo(next.dx, next.dy);
      canvas.drawPath(path, linePaint);

      final dotPaint = Paint()..color = color;
      canvas.drawCircle(current, 3, dotPaint);
      if (i == points.length - 2) {
        canvas.drawCircle(next, 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ColoredLineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
