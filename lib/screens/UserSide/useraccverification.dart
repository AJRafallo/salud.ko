import 'package:flutter/material.dart';
import 'package:saludko/screens/Opening/login_screen.dart';

class Useraccverification extends StatefulWidget {
  const Useraccverification({super.key});

  @override
  State<Useraccverification> createState() => _UseraccverificationState();
}

class _UseraccverificationState extends State<Useraccverification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text("Check your Email For Verification"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyLogin(),
                  ),
                );
              },
              child: const Text("Login"))
        ],
      ),
    );
  }
}
