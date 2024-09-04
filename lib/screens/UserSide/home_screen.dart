import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/appbar.dart';

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SaludkoAppBar(),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 1500, 20, 20),
                    child: Column(
                      children: [
                        Text(
                          "This is the HomeScreen",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Add more widgets as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
