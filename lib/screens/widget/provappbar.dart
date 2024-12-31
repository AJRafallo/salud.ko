import 'package:flutter/material.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/ProviderSide/PProfile.dart';

class SaludkoProvAppBar extends StatelessWidget {
  final Map<String, dynamic> provider;
  final String providerId;

  const SaludkoProvAppBar({
    super.key,
    required this.provider,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.blueAccent,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      pinned: true,
      expandedHeight: 150.0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "salud.ko",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.logout_rounded,
              size: 30,
              color: Colors.white,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            menuPadding: const EdgeInsets.all(0),
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthServices().signOut(); // Your logout service
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MyLogin(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, Dr. ${provider['firstname']}!",
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Welcome to salud.ko",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
