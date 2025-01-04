import 'package:flutter/material.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/Opening/signup_screen.dart';
import 'package:saludko/screens/ProviderSide/pverification1.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/widget/button.dart';
import 'package:saludko/screens/widget/snackbar.dart';
import 'package:saludko/screens/widget/textfield.dart';

class ProviderSignUpScreen extends StatefulWidget {
  @override
  _ProviderSignUpScreenState createState() => _ProviderSignUpScreenState();
}

class _ProviderSignUpScreenState extends State<ProviderSignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();

  bool isLoading = false;
  bool _isPasswordVisible = false; // Password visibility toggle

  String toTitleCase(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> signUpHealthcareProvider1() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthServices().signUpHealthCareProvider1(
      email: emailController.text,
      password: passwordController.text,
      firstname: toTitleCase(firstnameController.text),
      lastname: toTitleCase(lastnameController.text),
    );

    if (res == "Success") {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => EmailVerificationScreen(),
      ));
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final padding = mediaQuery.padding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - padding.top - padding.bottom,
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
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Are you a patient? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MySignup(),
                            ));
                      },
                      child: const Text(
                        "Register as user",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                MyButton(onTab: signUpHealthcareProvider1, text: "Sign Up"),
                const SizedBox(height: 15),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
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
