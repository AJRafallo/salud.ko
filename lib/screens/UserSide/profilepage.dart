import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/widget/button.dart';
import 'package:saludko/screens/widget/genderdropdown.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextStyle labelStyle = const TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
  );

  String? selectedGender;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String? profileImageUrl; // Variable to store profile image URL
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // This is where you can initialize any values if necessary
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${currentUser!.uid}.jpg');

        await storageRef.putFile(File(image.path));
        // Get the download URL
        profileImageUrl = await storageRef.getDownloadURL();
        // Update Firestore with new profile image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({'profileImage': profileImageUrl});

        setState(() {}); // Update the UI to show the new image
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A62B7),
        title: Align(
          alignment: Alignment.topRight, // Align the title to the right
          child: Container(
            margin: const EdgeInsets.only(right: 16.0), // Add margin if needed

            child: const Text(
              'User Profile',
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
            .collection('users')
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

          final user = snapshot.data!.data() as Map<String, dynamic>;

          // Initialize the controllers only if they are not already set
          if (firstNameController.text.isEmpty) {
            firstNameController.text = user['firstname'] ?? '';
          }
          if (middleNameController.text.isEmpty) {
            middleNameController.text = user['middlename'] ?? '';
          }
          if (lastNameController.text.isEmpty) {
            lastNameController.text = user['lastname'] ?? '';
          }
          if (emailController.text.isEmpty) {
            emailController.text = user['email'] ?? '';
          }
          if (phoneController.text.isEmpty) {
            phoneController.text = user['phone'] ?? '';
          }
          if (addressController.text.isEmpty) {
            addressController.text = user['Address'] ?? '';
          }
          ageController.text = ageController.text.isEmpty
              ? user['age']?.toString() ?? ''
              : ageController.text;

          // Load existing profile image URL if available
          profileImageUrl = user['profileImage'] ?? '';

          // Ensure selectedGender is set correctly only if it's not set
          selectedGender ??=
              (user['gender'] == 'Male' || user['gender'] == 'Female')
                  ? user['gender']
                  : null;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Upload
                  Center(
                    child: GestureDetector(
                      onTap: _uploadImage,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: profileImageUrl != null &&
                                profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : const AssetImage('lib/assets/images/avatar.png')
                                as ImageProvider,
                        child: (profileImageUrl == null ||
                                profileImageUrl!.isEmpty)
                            ? const Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // First Name Field
                  Text('First Name', style: labelStyle),
                  const SizedBox(height: 5),
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Middle Name Field
                  Text('Middle Name', style: labelStyle),
                  const SizedBox(height: 5),
                  TextField(
                    controller: middleNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Last Name Field
                  Text('Last Name', style: labelStyle),
                  const SizedBox(height: 5),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Email Field
                  Text('Email', style: labelStyle),
                  const SizedBox(height: 5),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Phone Field
                  Text('Phone', style: labelStyle),
                  const SizedBox(height: 5),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 10),

// Age Field
                  Text('Age', style: labelStyle), // Age label
                  const SizedBox(height: 5),
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 10.0), // Adjust padding
                    ),
                    keyboardType:
                        TextInputType.number, // Allows only numeric input
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter
                          .digitsOnly, // Restricts input to digits only
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Address Field
                  Text('Address', style: labelStyle),
                  const SizedBox(height: 5),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Gender Dropdown
                  Text('Gender', style: labelStyle),
                  const SizedBox(height: 5),
                  GenderDropdown(
                    selectedGender: selectedGender,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGender = newValue;
                        print(
                            'Selected Gender Updated: $newValue'); // Debug statement
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Spacer(), // Pushes the button to the right side
                      InkWell(
                        onTap: () async {
                          try {
                            // Prepare user data for update
                            final updatedUser = {
                              'firstname': firstNameController.text,
                              'middlename': middleNameController.text,
                              'lastname': lastNameController.text,
                              'email': emailController.text,
                              'phone': phoneController.text,
                              'Address': addressController.text,
                              'gender': selectedGender,
                              'profileImage':
                                  profileImageUrl, // Save the profile image URL
                              'age': ageController.text,
                            };

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser!.uid)
                                .update(updatedUser);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profile updated successfully!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Failed to update profile: $e')),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 20.0),
                            decoration: ShapeDecoration(
                              color: Colors.green, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30), // Rounded corners
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontSize: 15,
                                color: Colors.white, // Text color
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(height: 10),

                  const Divider(
                    // Horizontal line after the button
                    color: Colors.grey,
                    thickness: 1,
                    height: 10,
                    indent: 50,
                    endIndent: 50,
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
