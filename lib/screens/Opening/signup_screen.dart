import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/ProviderSignupPage.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/UserSide/home_screen.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/UserSide/waiting_screen.dart';
import 'package:saludko/screens/widget/button.dart';
import 'package:saludko/screens/widget/snackbar.dart';
import 'package:saludko/screens/widget/textfield.dart';

class MySignup extends StatefulWidget {
  const MySignup({super.key});

  @override
  State<MySignup> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<MySignup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    lastnameController.dispose();
    firstnameController.dispose();
  }

  void signUpUser() async {
    String res = await AuthServices().signUpUser(
      email: emailController.text,
      password: passwordController.text,
      lastname: lastnameController.text,
      firstname: firstnameController.text,
    );

    if (res.contains("Check your email")) {
      setState(() {
        isLoading = false;
      });

      showSnackBar(context, res);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VerificationWaitingScreen()),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  void _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;

    Timer.periodic(const Duration(seconds: 3), (timer) async {
      await user?.reload();
      if (user?.emailVerified ?? false) {
        timer.cancel();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const MyHomeScreen(),
        ));
      }
    });
  }

  // Function to show the sign-up dialog
  void _showSignupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sign Up'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyLogin()),
                  );
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputTextField(
                textEditingController: firstnameController,
                hintText: "Enter first name",
                icon: Icons.person_3_rounded,
              ),
              InputTextField(
                textEditingController: lastnameController,
                hintText: "Enter last name",
                icon: Icons.person_3_rounded,
              ),
              InputTextField(
                textEditingController: emailController,
                hintText: "Enter email",
                icon: Icons.email_rounded,
              ),
              InputTextField(
                textEditingController: passwordController,
                hintText: "Enter password",
                isPass: !_isPasswordVisible,
                icon: Icons.lock_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              MyButton(onTab: signUpUser, text: "Sign Up"),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Sign up | salud.ko",
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 50),
                // Your normal form fields
                InputTextField(
                  textEditingController: firstnameController,
                  hintText: "Enter first name",
                  icon: Icons.person_3_rounded,
                ),
                InputTextField(
                  textEditingController: lastnameController,
                  hintText: "Enter last name",
                  icon: Icons.person_3_rounded,
                ),
                InputTextField(
                  textEditingController: emailController,
                  hintText: "Enter email",
                  icon: Icons.email_rounded,
                ),
                InputTextField(
                  textEditingController: passwordController,
                  hintText: "Enter password",
                  isPass: !_isPasswordVisible,
                  icon: Icons.lock_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Are you a healthcare provider?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProviderSignup(),
                            ));
                      },
                      child: const Text(
                        "Register as healthcare provider",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                MyButton(
                  onTab: _showSignupDialog, // Show the dialog on sign up
                  text: "Sign Up",
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyLogin(),
                            ));
                      },
                      child: const Text(
                        " Log In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
