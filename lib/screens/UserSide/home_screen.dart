import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/VerifiedListing.dart';
import 'package:saludko/screens/widget/appbar.dart'; // Custom app bar that will accept user data
import 'package:saludko/screens/widget/healthcarefacilitieslist.dart';
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

  // Handle navigation between screens
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users') // Fetch data from the 'users' collection
            .doc(currentUser.uid) // Get the logged-in user's ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          // Fetch user data from Firestore snapshot
          final userData = snapshot.data!.data() as Map<String, dynamic>;

          // Define the screens with user data being passed to SavedScreen and SaludkoAppBar
          final homeScreen = Scaffold(
            body: CustomScrollView(
              slivers: [
                SaludkoAppBar(
                  userData: userData, // Pass the fetched user data to the app bar
                  userId: currentUser.uid, // Pass the user ID
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Healthcare Facilities",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                              ),
                            ),
                            HealthcareFacilities(),
                            SizedBox(height: 10),
                            Text(
                              "Healthcare Providers",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                              ),
                            ),
                            VerifiedProvidersWidget(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          // Update screens with the correct home screen
          final List<Widget> screens = [
            homeScreen,
            SavedScreen(userData: userData, userId: currentUser.uid), // Pass userData to SavedScreen
            const RecordsScreen(),
            const HotlinesScreen(),
          ];

          return Scaffold(
            body: screens[_selectedIndex],
            bottomNavigationBar: CustomNavBar(
              selectedIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        },
      ),
    );
  }
}
