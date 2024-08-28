import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/ProviderSignupPage.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/UserSide/home_screen.dart';
import 'package:saludko/screens/login_screen.dart';
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
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override

  void dispose(){
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void signUpUser() async {
    String res = await AuthServices().signUpUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text);

    if (res == "Success") {
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MyHomeScreen(),
      ));
    }
    else{
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
          child: ConstrainedBox(constraints: BoxConstraints(
             minHeight: screenHeight - padding.top - padding.bottom,
          ),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //const SizedBox(height: 150),
            const Text(
              "Sign up | salud.ko",
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 50),
            InputTextField(
              textEditingController: nameController,
              hintText: "Enter name",
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
            MyButton(onTab: signUpUser, text: "Sign Up"),
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
            )
          ],
        ),
        )
      ),
      )
    );
  }
}
