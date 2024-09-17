import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/VerifiedListing.dart';
import 'package:saludko/screens/widget/adminappbar.dart';
import 'package:saludko/screens/widget/adminbotnav.dart';

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          AdminAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, 0), // Adjust bottom padding to 0
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Healthcare Providers",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                      ),
                    ],
                  ),
                  VerifiedProvidersWidget(), // Directly add the widget here
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Adminbotnav(),
    );
  }
}
