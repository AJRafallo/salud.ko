import 'package:flutter/material.dart';

class AllHealthDataHeader extends StatelessWidget {
  final VoidCallback onAddTapped;
  final VoidCallback onEditTapped;

  const AllHealthDataHeader({
    Key? key,
    required this.onAddTapped,
    required this.onEditTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "All Health Data",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            // + Button
            GestureDetector(
              onTap: onAddTapped,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
            // Edit Button
            GestureDetector(
              onTap: onEditTapped,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
