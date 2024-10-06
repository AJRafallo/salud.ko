import 'package:flutter/material.dart';
import 'package:saludko/screens/HospitalAdminSide/HospitalAdHomepage.dart';
import 'package:saludko/screens/HospitalAdminSide/HospitalAdVerificationPage.dart';

class Hospitaladbotnav extends StatefulWidget {
  const Hospitaladbotnav({super.key});

  @override
  _HospitaladbotnavState createState() => _HospitaladbotnavState();
}

class _HospitaladbotnavState extends State<Hospitaladbotnav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Use pushReplacement to avoid building a new BottomNavigationBar
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HospitalAdHomeScreen(), // Homepage route
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const HospitalAdDashboard(), // Admin verification route
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blueAccent, // Color for the selected item
      unselectedItemColor: Colors.grey, // Color for the unselected items
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pending),
          label: 'Verify Providers',
        ),
      ],
    );
  }
}
