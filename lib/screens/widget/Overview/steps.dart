import 'package:flutter/material.dart';

class StepsCardWidget extends StatelessWidget {
  final double monthlyStepsPercentage;
  final double milesWalked;

  const StepsCardWidget({
    super.key,
    required this.monthlyStepsPercentage,
    required this.milesWalked,
  });

  @override
  Widget build(BuildContext context) {
    Color progressColor = const Color(0xFFFFA8B4);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFCCE3FF),
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_walk,
                    size: 22, color: Colors.black),
              ),
              const SizedBox(width: 12),
              const Text(
                "Steps",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${(monthlyStepsPercentage * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Total this month",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: monthlyStepsPercentage,
                      strokeWidth: 3,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF1A62B7), width: 3),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            milesWalked.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "miles",
                            style:
                                TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
