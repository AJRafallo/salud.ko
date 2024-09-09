import 'package:flutter/material.dart';
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
    // Add your actual home screen widget here if it's different from the current one
    Scaffold(
      body: CustomScrollView(
        slivers: [
          const SaludkoAppBar(),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
                    child: Column(
                      children: [
                        Text(
                          "This is the HomeScreen",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
