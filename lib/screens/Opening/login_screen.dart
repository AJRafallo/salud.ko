import 'package:flutter/material.dart';
import 'package:saludko/screens/AdminSide/VerificationPage.dart';
import 'package:saludko/screens/HospitalAdminSide/HospitalAdHomepage.dart';
import 'package:saludko/screens/ProviderSide/ProviderHomepage.dart';
import 'package:saludko/screens/ProviderSide/ProviderVerificationStatusPage.dart';
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
      // Navigate to the user's home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomeScreen(),
        ),
      );
    } else if (role == "healthcare_provider") {
      // Navigate to the healthcare provider's home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ProviderHomeScreen(),
        ),
      );
    } else if (role == "not_verified") {
      // Navigate to the verification status screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ProviderVerificationStatusScreen(),
        ),
      );
    } else if (role == "admin") {
      // Navigate to the admin's home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
        ),
      );
    } else if (role == "hospital_admin") {
      // Navigate to the hospital admin's home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HospitalAdHomeScreen(),
        ),
      );
    } else {
      // Show an error message
      showSnackBar(context, role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'salud.ko',
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
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
                isPass: true,
                icon: Icons.lock_rounded,
              ),
              /*const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),*/
              const SizedBox(height: 20),
              MyButton(onTab: logInUser, text: "Login"),
              const SizedBox(height: 15),
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
