import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saludko/screens/widget/button.dart';

class ProviderProfile extends StatelessWidget {
  const ProviderProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('healthcare_providers')
            .doc(currentUser.uid) // Use the logged-in user's ID to get their data
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Provider data not found.'));
          }

          final provider = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.edit
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: TextEditingController(text: provider['firstname']),
                        decoration: const InputDecoration(labelText: 'First Name'),
                        onChanged: (value) {
                          provider['firstname'] = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: TextEditingController(text: provider['lastname']),
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        onChanged: (value) {
                          provider['lastname'] = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: TextEditingController(text: provider['email']),
                        decoration: const InputDecoration(labelText: 'Email'),
                        onChanged: (value) {
                          provider['email'] = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: TextEditingController(text: provider['phone']),
                        decoration: const InputDecoration(labelText: 'Phone'),
                        onChanged: (value) {
                          provider['phone'] = value;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('healthcare_providers')
                                .doc(currentUser.uid)
                                .update(provider);
                  
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated successfully!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update profile: $e')),
                            );
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        onTab: () async {
                          await AuthServices().signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const MyLogin()),
                          );
                        },
                        text: "Logout",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
