import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/VerifiedListing.dart';
import 'package:saludko/screens/widget/appbar.dart';

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SaludkoAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 1500, 20, 0), // Adjust bottom padding to 0
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /*Text(
                    "Healthcare Providers",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),*/
                  //SizedBox(height: 10), // Add small spacing
                  VerifiedProvidersWidget(), // Directly add the widget here
                ],
              ),
            ),
          ),
          // If you have more widgets to be scrolled
        ],
      ),
    );
  }
}
