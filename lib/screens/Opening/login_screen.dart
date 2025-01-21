import 'package:flutter/material.dart';
import 'package:saludko/screens/AdminSide/AdminHP.dart';
import 'package:saludko/screens/HospitalAdminSide/HAHomepage.dart';
import 'package:saludko/screens/ProviderSide/ProviderHP.dart';
import 'package:saludko/screens/ProviderSide/pverification1.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/UserSide/home_screen.dart';
import 'package:saludko/screens/Opening/signup_screen.dart';
import 'package:saludko/screens/widget/button.dart';
import 'package:saludko/screens/widget/snackbar.dart';
import 'package:saludko/screens/widget/textfield.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false; // State variable for password visibility

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void logInUser() async {
    setState(() {
      isLoading = true;
    });

    String role = await AuthServices().logInUser(
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (role == "user") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomeScreen(),
        ),
      );
    } else if (role == "healthcare_provider") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ProviderHP(),
        ),
      );
    } else if (role == "not_verified") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const EmailVerificationScreen(),
        ),
      );
    } else if (role == "admin") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AdminHP(),
        ),
      );
    } else if (role == "hospital_admin") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HAdminHomeScreen(),
        ),
      );
    } else {
      showSnackBar(context, role);
    }
  }

  void resetPassword() {
    // You can display a dialog or navigate to a reset password screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          decoration: const InputDecoration(hintText: "Enter your email"),
          controller: emailController,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              String response =
                  await AuthServices().resetPassword(emailController.text);
              showSnackBar(
                  context, response); // Show a success or error message
            },
            child: const Text("Send Reset Link"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Log in | salud.ko",
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 50),
              InputTextField(
                textEditingController: emailController,
                hintText: "Enter email",
                icon: Icons.email_rounded,
              ),
              InputTextField(
                textEditingController: passwordController,
                hintText: "Enter password",
                isPass: !_isPasswordVisible, // Toggle visibility
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
              GestureDetector(
                onTap: resetPassword,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MyButton(onTab: logInUser, text: "Login"),
              const SizedBox(height: 15),
              /*ElevatedButton(onPressed: AuthServices().signInWithGoogle, child: const Text('Google Sign In')),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MySignup(),
                        ),
                      );
                    },
                    child: const Text(
                      " Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
