import 'package:flutter/material.dart';

class GenderDropdown extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderDropdown({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), // Adjust padding

      ),
      items: ['Male', 'Female'].map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              )),
        );
      }).toList(),
      onChanged: onChanged,
      hint: const Text('Select Gender'), // Optional hint
    );
  }
}
