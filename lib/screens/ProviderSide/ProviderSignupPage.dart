import 'package:flutter/material.dart'; 
import 'package:saludko/screens/ProviderSide/ProviderVerificationStatusPage.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/Opening/signup_screen.dart';
import 'package:saludko/screens/widget/button.dart';
import 'package:saludko/screens/widget/snackbar.dart';
import 'package:saludko/screens/widget/textfield.dart';
import 'package:saludko/screens/widget/workplacedropdown.dart';

class ProviderSignup extends StatefulWidget {
  const ProviderSignup({super.key});

  @override
  State<ProviderSignup> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<ProviderSignup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();

  String? selectedWorkplace; // Variable to store the selected workplace
  bool isLoading = false;

  final List<String> workplaces = [
    "Mother Seton",
    "Bicol Medical Center",
    "Our Lady of Fatima",
    // Add more workplace options here
  ];

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    lastnameController.dispose();
    firstnameController.dispose();
  }

  void signUpHealthCareProvider() async {
  if (selectedWorkplace == null) {
    showSnackBar(context, 'Please select a workplace.');
    return;
  }

  // Force unwrap selectedWorkplace since it's confirmed to be non-null
  String res = await AuthServices().signUpHealthCareProvider(
    email: emailController.text,
    password: passwordController.text,
    lastname: lastnameController.text,
    firstname: firstnameController.text,
    workplace: selectedWorkplace!, // Use the non-null assertion here
  );

  if (res == "Success") {
    setState(() {
      isLoading = true;
    });
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const ProviderVerificationStatusScreen(),
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
                  isPass: true,
                  icon: Icons.lock_rounded,
                ),
                
              WorkplaceDropdown(
                selectedWorkplace: selectedWorkplace,
                workplaces: workplaces,
                onChanged: (newValue) {
                  setState(() {
                    selectedWorkplace = newValue;
                  });
                },
              ),

                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Are you a patient/caregiver?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MySignup(),
                            ));
                      },
                      child: const Text(
                        "Register as a user",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                MyButton(onTab: signUpHealthCareProvider, text: "Sign Up"),
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
