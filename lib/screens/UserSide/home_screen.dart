import 'package:flutter/material.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/login_screen.dart';
import 'package:saludko/screens/widget/button.dart';

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is the HomeScreen",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),),
            MyButton(onTab: () async {
              await AuthServices().signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const MyLogin()));
            }, text: "Logout")
          ],
        ),
      ),
    );
  }
}