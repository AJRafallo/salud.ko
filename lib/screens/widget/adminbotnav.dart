import 'package:flutter/material.dart';
import 'package:saludko/screens/AdminSide/AdminHomepage.dart';
import 'package:saludko/screens/AdminSide/VerificationPage.dart';

class Adminbotnav extends StatefulWidget {
  const Adminbotnav({super.key});

  @override
  _AdminbotnavState createState() => _AdminbotnavState();
}

class _AdminbotnavState extends State<Adminbotnav> {
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
          builder: (context) => const AdminHomepage(), // Homepage route
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(), // Admin verification route
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.grey, // Color for the selected item
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
