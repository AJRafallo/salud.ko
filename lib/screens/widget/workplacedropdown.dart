import 'package:flutter/material.dart';

class WorkplaceDropdown extends StatelessWidget {
  final String? selectedWorkplace;
  final List<String> workplaces;
  final ValueChanged<String?> onChanged;

  const WorkplaceDropdown({
    super.key,
    required this.selectedWorkplace,
    required this.workplaces,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedWorkplace,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          prefixIcon: const Icon(Icons.place),
          filled: true,
          fillColor: Colors.white70,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.blueGrey),
            borderRadius: BorderRadius.circular(30),
      
          ),
        ),
        hint: const Text(
          "Select Workplace",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),

        items: workplaces.map((String workplace) {
          return DropdownMenuItem<String>(
            value: workplace,
            child: Text(
              workplace,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true, // Ensures the dropdown takes up full width
        dropdownColor: Colors.white, // Background color for dropdown menu
      ),
    );
  }
}
