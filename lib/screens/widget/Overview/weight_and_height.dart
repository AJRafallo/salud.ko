import 'package:flutter/material.dart';

class WeightHeightCardWidget extends StatelessWidget {
  final double weight;
  final double height;
  final String Function(double) formatNumber;
  final VoidCallback onEditPressed;

  const WeightHeightCardWidget({
    Key? key,
    required this.weight,
    required this.height,
    required this.formatNumber,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF9ECBFF), width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      // Keep padding moderate so it won’t crowd the layout
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row + Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weight",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: onEditPressed,
                icon: const Icon(Icons.more_horiz, color: Color(0xFF1A62B7)),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  formatNumber(weight),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Flexible(
                child: Text(
                  "KG",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A62B7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Height",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  formatNumber(height),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Flexible(
                child: Text(
                  "CM",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A62B7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
