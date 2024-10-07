import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFFF3EDF7),
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: _buildNavItem(
            icon: Icons.home_outlined,
            filledIcon: Icons.home,
            index: 0,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildNavItem(
            icon: Icons.bookmark_border,
            filledIcon: Icons.bookmark,
            index: 1,
          ),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: _buildNavItem(
            icon: Icons.folder_open_outlined,
            filledIcon: Icons.folder,
            index: 2,
          ),
          label: 'Records',
        ),
        BottomNavigationBarItem(
          icon: _buildNavItem(
            icon: Icons.phone_outlined,
            filledIcon: Icons.phone,
            index: 3,
          ),
          label: 'Hotlines',
        ),
      ],
      selectedItemColor: const Color(0xFF1E1E1E),
      unselectedItemColor: const Color(0xFF49454F),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon,
      required IconData filledIcon,
      required int index}) {
    final bool isSelected = selectedIndex == index;

    return Container(
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFFE8DEF8),
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      padding: const EdgeInsets.all(8), // Adjust padding to fit the shape
      child: Icon(
        isSelected ? filledIcon : icon,
        color: isSelected ? const Color(0xFF1E1E1E) : const Color(0xFF49454F),
      ),
    );
  }
}
