import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:saludko/screens/widget/genderdropdown.dart';

class ProviderProfile extends StatefulWidget {
  const ProviderProfile({super.key});

  @override
  _ProviderProfileState createState() => _ProviderProfileState();
}

class _ProviderProfileState extends State<ProviderProfile> {
  final TextStyle labelStyle = const TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
  );

  String? selectedGender; // Variable to store selected gender
  String? profileImageUrl; // Variable to store profile image URL
  final currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController workplaceController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController workaddressController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    workplaceController.dispose();
    ageController.dispose();
    descriptionController.dispose();
    workaddressController.dispose();
    specializationController.dispose();
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
            .child('provider_images/${currentUser!.uid}.jpg');

        await storageRef.putFile(File(image.path));
        // Get the download URL
        profileImageUrl = await storageRef.getDownloadURL();
        // Update Firestore with new profile image URL
        await FirebaseFirestore.instance
            .collection('healthcare_providers')
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
              'Healthcare Provider Profile',
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
            .collection('healthcare_providers')
            .doc(currentUser!
                .uid) // Use the logged-in user's ID to get their data
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
// Setting the text only if the TextEditingController is empty
          firstNameController.text = firstNameController.text.isEmpty
              ? provider['firstname'] ?? ''
              : firstNameController.text;


          middleNameController.text = middleNameController.text.isEmpty
              ? provider['middlename'] ?? ''
              : middleNameController.text;

          lastNameController.text = lastNameController.text.isEmpty
              ? provider['lastname'] ?? ''
              : lastNameController.text;

          emailController.text = emailController.text.isEmpty
              ? provider['email'] ?? ''
              : emailController.text;

          phoneController.text = phoneController.text.isEmpty
              ? provider['phone'] ?? ''
              : phoneController.text;

          addressController.text = addressController.text.isEmpty
              ? provider['Address'] ?? ''
              : addressController.text;

          workplaceController.text = workplaceController.text.isEmpty
              ? provider['workplace'] ?? ''
              : workplaceController.text;

          ageController.text = ageController.text.isEmpty
              ? provider['age']?.toString() ?? ''
              : ageController.text;

          descriptionController.text = descriptionController.text.isEmpty
              ? provider['description']?.toString() ?? ''
              : descriptionController.text;

          workaddressController.text = workaddressController.text.isEmpty
              ? provider['workaddress']?.toString() ?? ''
              : workaddressController.text;

          specializationController.text = specializationController.text.isEmpty
              ? provider['specialization']?.toString() ?? ''
              : specializationController.text;


          // Load existing profile image URL if available
          profileImageUrl = provider['profileImage'] ?? '';

          // Ensure selectedGender is set correctly only if it's not set
          selectedGender ??=
              (provider['gender'] == 'Male' || provider['gender'] == 'Female')
                  ? provider['gender']
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

                  const SizedBox(height: 30),

                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Wrap fields in a Container
                  Container(
                    padding:
                        const EdgeInsets.all(20.0), // Padding around the fields
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Optional border
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Name Field
                        Text('First Name', style: labelStyle),
                        const SizedBox(height: 5),
                        TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
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
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
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
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
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
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
                          ),
                          keyboardType:
                              TextInputType.number, // Allows only numeric input
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter
                                .digitsOnly, // Restricts input to digits only
                          ],
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),

                        // Phone Field
                        Text('Phone', style: labelStyle),
                        const SizedBox(height: 5),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Address Field
                        Text('Address', style: labelStyle),
                        const SizedBox(height: 5),
                        TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Description Field
                        Text('Description', style: labelStyle),
                        const SizedBox(height: 5),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25.0, horizontal: 10.0),
                            // Adjust padding
                          ),
                          minLines: 1,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Professional Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding:
                        const EdgeInsets.all(20.0), // Padding around the fields
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Optional border
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Workplace Field
                        Text('Workplace', style: labelStyle),
                        const SizedBox(height: 5),
                        TextField(
                          controller: workplaceController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
                          ),
                          readOnly: true, // This makes the TextField ineditable
                        ),

                        const SizedBox(height: 10),

                        // Work Address Field
                        Text('Work Address', style: labelStyle),
                        const SizedBox(height: 5),
                        TextField(
                          controller: workaddressController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 10.0), // Adjust padding
                          ),
                          minLines: 1, // Minimum number of lines
                          maxLines: 5,
                          readOnly: true, // This makes the TextField ineditable
                        ),

                        const SizedBox(height: 10),

                        // Specialization Field
                        Text('Specialization', style: labelStyle),
                        const SizedBox(height: 5),
                        TextField(
                          controller: specializationController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0), // Adjust padding
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Spacer(), // Pushes the button to the right side
                      InkWell(
                        onTap: () async {
                          try {
                            // Prepare user data for update
                            final updatedProvider = {
                              'firstname': firstNameController.text,
                              'middlename': middleNameController.text,
                              'lastname': lastNameController.text,
                              'email': emailController.text,
                              'phone': phoneController.text,
                              'Address': addressController.text,
                              'gender': selectedGender,
                              'profileImage':
                                  profileImageUrl, // Save the profile image URL
                              'description': descriptionController.text,
                              'workaddress': workaddressController.text,
                              'specialization': specializationController.text,
                              'age': ageController.text,
                            };

                            await FirebaseFirestore.instance
                                .collection('healthcare_providers')
                                .doc(currentUser!.uid)
                                .update(updatedProvider);

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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<GeoPoint?> getFacilityLocation(String workplace) async {
  final QuerySnapshot facilitySnapshot = await FirebaseFirestore.instance
      .collection('hospital')
      .where('workplace', isEqualTo: workplace)
      .get();

  if (facilitySnapshot.docs.isNotEmpty) {
    // Assuming location is stored as a GeoPoint in your facility documents
    final facilityData =
        facilitySnapshot.docs.first.data() as Map<String, dynamic>;
    return facilityData['location'] as GeoPoint?;
  }
  return null; // Return null if no facility is found
}
