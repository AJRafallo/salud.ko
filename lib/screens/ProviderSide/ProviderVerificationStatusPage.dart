import 'package:flutter/material.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/widget/button.dart';

class ProviderVerificationStatusScreen extends StatelessWidget {
  const ProviderVerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20), // Space inside the box
          margin: const EdgeInsets.fromLTRB(20, 150, 20, 150), // Space outside the box
          decoration: BoxDecoration(
            color: Colors.white, // Background color of the box
            border: Border.all(
              color: Colors.blue, // Border color
              width: 2, // Border width
            ),
            borderRadius: BorderRadius.circular(15), // Rounded corners
            boxShadow: const [
              BoxShadow(
                color: Colors.grey, // Shadow color
                offset: Offset(2, 2), // Shadow position
                blurRadius: 5, // Shadow blur radius
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Account Under Verification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Your account is currently undergoing verification. Please wait until it is approved by the admin.',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              MyButton(onTab: () async {
              await AuthServices().signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const MyLogin()));
            }, text: "Logout")
            ],
          ),
        ),
      ),
    );
  }
}
