import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/appbar_2.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SaludkoAppBar(), // Use your custom app bar here
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
                    child: Column(
                      children: [
                        Text(
                          "This is the Health Records Screen",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        // Add more widgets as needed
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
