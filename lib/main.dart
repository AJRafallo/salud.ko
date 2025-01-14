import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/AdminSide/AdminHP.dart';
import 'package:saludko/screens/HospitalAdminSide/HAHomepage.dart';
import 'package:saludko/screens/ProviderSide/ProviderHP.dart';
import 'package:saludko/screens/ProviderSide/pverification1.dart';
import 'package:saludko/screens/UserSide/home_screen.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/Opening/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if user exists in 'users' collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return 'user';
      }

      // Check if user exists in 'healthcare_providers' collection
      DocumentSnapshot providerDoc = await FirebaseFirestore.instance
          .collection('healthcare_providers')
          .doc(user.uid)
          .get();
      if (providerDoc.exists) {
        bool isVerified = providerDoc.get('isVerified');
        if (isVerified) {
          return 'healthcare_provider';
        } else {
          return 'not_verified';
        }
      }

      // Check if user exists in 'admins' collection
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();
      if (adminDoc.exists) {
        return 'admin';
      }

      // Check if user exists in 'hospital' collection with role 'hospital_admin'
      DocumentSnapshot hospitalDoc = await FirebaseFirestore.instance
          .collection('hospital')
          .doc(user.uid)
          .get();
      if (hospitalDoc.exists && hospitalDoc.get('role') == 'hospital_admin') {
        return 'hospital_admin';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: _getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen(); // Show splash screen while loading
          } else if (snapshot.hasData) {
            // Navigate to the correct home screen based on the user role
            if (snapshot.data == 'user') {
              return const MyHomeScreen();
            } else if (snapshot.data == 'healthcare_provider') {
              return const ProviderHP();
            } else if (snapshot.data == 'admin') {
              return const AdminHP();
            } else if (snapshot.data == 'hospital_admin') {
              return const HAdminHomeScreen(); // Redirect hospital admin to their homepage
            } else if (snapshot.data == 'not_verified') {
              return const EmailVerificationScreen();
            } else {
              return const MyLogin(); // Redirect to login if the role is not found
            }
          } else {
            return const SplashScreen(); // Redirect to login if not authenticated
          }
        },
      ),
    );
  }
}
