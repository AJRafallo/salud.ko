import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/ProviderSide/psignup2.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isVerified = false;
  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    checkInitialEmailVerification();
  }

  Future<void> checkInitialEmailVerification() async {
    User? user = _auth.currentUser;
    await user?.reload(); // Reload user to ensure fresh data
    setState(() {
      isVerified = user?.emailVerified ?? false;
    });

    if (isVerified) {
      navigateToNextPage();
    }
  }

  Future<void> checkEmailVerification() async {
    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;
    await user?.reload(); // Reload user to update verification status

    if (user != null && user.emailVerified) {
      setState(() {
        isVerified = true;
      });
      navigateToNextPage();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Email not verified yet. Please check your email.")),
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    setState(() {
      isResending = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Verification email sent. Please check your inbox.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isResending = false;
      });
    }
  }

  void navigateToNextPage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const ProfessionalDetailsSignupPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(350),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A62B7), // Background color of the AppBar
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50), // Adjust radius for circular effect
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            toolbarHeight: 350,
            automaticallyImplyLeading: false, // Prevent default back button
            title: Column(
              children: [
                Align(
                  alignment: Alignment.topRight, // Align the icon to the left
                  child: IconButton(
                    icon: const Icon(Icons.login),
                    tooltip: 'Back to login',
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyLogin(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 150),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Verify your account first!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Check your email to verify.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "A verification link has been sent to your email address. Please verify your email to proceed.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            isResending
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: resendVerificationEmail,
                    child: const Text(
                      "Resend Verification Email",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: checkEmailVerification,
                    child: const Text(
                      "Email Verified",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
