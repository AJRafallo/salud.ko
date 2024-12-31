import 'dart:async';
import 'dart:ui'; // For the BackdropFilter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/UserSide/home_screen.dart';
import 'package:saludko/screens/widget/snackbar.dart';

class VerificationWaitingScreen extends StatefulWidget {
  const VerificationWaitingScreen({super.key});

  @override
  State<VerificationWaitingScreen> createState() =>
      _VerificationWaitingScreenState();
}

class _VerificationWaitingScreenState extends State<VerificationWaitingScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If the user is not logged in, navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // Wait for the email verification status to be updated
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        await user.reload(); // Refresh user data

        // Debug log to check if user data is being refreshed
        print('User emailVerified: ${user.emailVerified}');

        if (user.emailVerified) {
          timer.cancel(); // Stop checking once verified
          Navigator.of(context).pop(); // Dismiss the modal dialog
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MyHomeScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      showSnackBar(context, "Verification email resent.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // This is the blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter:
                ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Apply blur effect
            child: Container(
              color: Colors.white
                  .withOpacity(0.5), // Optional, to darken the background
            ),
          ),
        ),
        // The dialog content
        Center(
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the title
              children: [
                Text(
                  "Email Verification",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "A verification email has been sent to your email address. "
                    "Please verify your email to proceed.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resendVerificationEmail,
                    child: const Text("Resend Email"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Check if the email is verified
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null && user.emailVerified) {
                        // Navigate to the home screen if verified
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const MyHomeScreen()),
                        );
                      } else {
                        // Show message to verify email first
                        showSnackBar(
                            context, "Please verify your account first.");
                      }
                    },
                    child: const Text("Email Verified"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
