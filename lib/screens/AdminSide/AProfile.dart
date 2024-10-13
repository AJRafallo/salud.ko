import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/AdminSide/AdminProfile.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/widget/button.dart';

class AdminShowProfile extends StatefulWidget {
  const AdminShowProfile({super.key});

  @override
  _AdminShowProfileState createState() => _AdminShowProfileState();
}

class _AdminShowProfileState extends State<AdminShowProfile> {
  final TextStyle labelStyle = const TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
  );

  String? selectedGender;

  String? profileImageUrl; // Variable to store profile image URL
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // This is where you can initialize any values if necessary
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Align(
          alignment: Alignment.topRight, // Align the title to the right
          child: Container(
            margin: const EdgeInsets.only(right: 16.0), // Add margin if needed

            child: const Text(
              'salud.ko Admin Profile',
              style: TextStyle(
                color: Colors.white, // Change the text color
                fontSize: 20, // Change the font size
                fontWeight: FontWeight.bold, // Change the font weight
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admins')
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          final admin = snapshot.data!.data() as Map<String, dynamic>;

          // Load existing profile image URL if available
          profileImageUrl = admin['profileImage'] ?? '';

          // Ensure selectedGender is set correctly only if it's not set
          selectedGender ??=
              (admin['gender'] == 'Male' || admin['gender'] == 'Female')
                  ? admin['gender']
                  : null;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.all(25.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A62B7),
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminProfile(),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          Center(
                            child: GestureDetector(
                              child: CircleAvatar(
                                radius: 100,
                                backgroundImage: profileImageUrl != null &&
                                        profileImageUrl!.isNotEmpty
                                    ? NetworkImage(profileImageUrl!)
                                    : const AssetImage(
                                            'lib/assets/images/avatar.png')
                                        as ImageProvider,
                                child: (profileImageUrl == null ||
                                        profileImageUrl!.isEmpty)
                                    ? const Icon(Icons.camera_alt,
                                        size: 40, color: Colors.grey)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(children: [
                              Text(
                                "${admin['lastname'] ?? ''}, ${admin['firstname'] ?? ''} ${admin['middlename'] ?? ''}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
                                "salud.ko Administrator",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ]),
                          )
                        ],
                      )),

                  const SizedBox(height: 20),

                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding:
                        const EdgeInsets.all(20.0), // Padding around the fields
                    width: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Optional border
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Icon(
                                    Icons.email_rounded,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                                Text("${admin['email'] ?? ''}"),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Icon(
                                    Icons.call_rounded,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                                Text("${admin['phone'] ?? ''}"),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Icon(
                                    Icons.map_rounded,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                                Text("${admin['Address'] ?? ''}"),
                              ],
                            ),
                            const SizedBox(height: 5),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(
                    // Horizontal line after the button
                    color: Colors.grey,
                    thickness: 1,
                    height: 10,
                  ),

                  // Logout Button
                  MyButton(
                    onTab: () async {
                      await AuthServices().signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const MyLogin()),
                      );
                    },
                    text: "Logout",
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
