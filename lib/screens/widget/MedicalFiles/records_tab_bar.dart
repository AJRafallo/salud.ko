import 'package:flutter/material.dart';

class RecordsNavigation extends StatelessWidget {
  final String selectedPage;
  final Function(String) onPageSelected;

  const RecordsNavigation({
    super.key,
    required this.selectedPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      margin: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavigationItem(
              "Overview", screenWidth, selectedPage == "Overview"),
          _buildNavigationItem("Medicine Reminders", screenWidth,
              selectedPage == "Medicine Reminders"),
          _buildNavigationItem(
              "Medical Files", screenWidth, selectedPage == "Medical Files"),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
      String title, double screenWidth, bool isSelected) {
    return GestureDetector(
      onTap: () => onPageSelected(title),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2555FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }
}
