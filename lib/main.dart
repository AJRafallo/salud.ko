import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:saludko/screens/Services/localnotifications.dart';
import 'package:saludko/screens/AdminSide/AdminHP.dart';
import 'package:saludko/screens/HospitalAdminSide/HAHomepage.dart';
import 'package:saludko/screens/ProviderSide/ProviderHP.dart';
import 'package:saludko/screens/ProviderSide/pverification1.dart';
import 'package:saludko/screens/UserSide/home_screen.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/Opening/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Firebase
  await Firebase.initializeApp();

  // 2) Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Manila'));

  // 3) Local notifications plugin
  await LocalNotificationService.initialize();

  // 4) Request runtime notification permission on Android 13+
  await requestAndroid13NotificationPermission();

  runApp(const MyApp());
}

Future<void> requestAndroid13NotificationPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return 'user';
      }

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

      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();
      if (adminDoc.exists) {
        return 'admin';
      }

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
            return const SplashScreen();
          } else if (snapshot.hasData) {
            final role = snapshot.data;
            if (role == 'user') {
              return const MyHomeScreen();
            } else if (role == 'healthcare_provider') {
              return const ProviderHP();
            } else if (role == 'admin') {
              return const AdminHP();
            } else if (role == 'hospital_admin') {
              return const HAdminHomeScreen();
            } else if (role == 'not_verified') {
              return const EmailVerificationScreen();
            } else {
              return const MyLogin();
            }
          } else {
            // User not logged in or unknown
            return const SplashScreen();
          }
        },
      ),
    );
  }
}
