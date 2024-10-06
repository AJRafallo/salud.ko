import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/VerifiedListing.dart';
import 'package:saludko/screens/widget/appbar.dart';
import 'package:saludko/screens/widget/navbar.dart';
import 'package:saludko/screens/UserSide/saved_screen.dart';
import 'package:saludko/screens/UserSide/records_screen.dart';
import 'package:saludko/screens/UserSide/hotlines_screen.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // Example of the home screen widget
    const Scaffold(
      body: CustomScrollView(
        slivers: [
          SaludkoAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0), // Adjust bottom padding to 0
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                     "Healthcare Providers",
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 20,
                     ),
                  ),
                  VerifiedProvidersWidget(), // Ensure this widget is defined
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    const SavedScreen(), // Ensure this import is correct
    const RecordsScreen(), // Ensure this import is correct
    const HotlinesScreen(), // Ensure this import is correct
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
