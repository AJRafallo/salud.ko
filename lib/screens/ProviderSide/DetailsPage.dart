import 'package:flutter/material.dart';

class ProviderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Provider Profile'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              print('Back button pressed');
              Navigator.of(context).pop();
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${provider['firstname']} ${provider['lastname']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Email: ${provider['email']}'),
            const SizedBox(height: 10),
            // Add more provider details here
            // e.g., Text('Phone: ${provider['phone']}'),
            //       Text('Address: ${provider['address']}'),
          ],
        ),
      ),
    );
  }
}
