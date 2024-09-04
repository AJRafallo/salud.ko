import 'package:flutter/material.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/widget/button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
            Navigator.pop(context); // Simply pop the current screen
        },
      ),
      title: const Text(
        "salud.ko",
        style: TextStyle(
          fontSize: 15,
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.person,
            ),
          ),
        ),
      ],
    ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is the Profile Page",
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