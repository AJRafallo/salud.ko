import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:saludko/screens/ProviderSide/ProviderVerificationStatusPage.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/widget/button.dart';
import 'package:saludko/screens/widget/snackbar.dart';
import 'package:saludko/screens/widget/textfield.dart';
import 'package:saludko/screens/widget/workplacedropdown.dart';

class ProviderSignup extends StatefulWidget {
  const ProviderSignup({super.key});

  @override
  State<ProviderSignup> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<ProviderSignup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();

  String? selectedWorkplace;
  bool isLoading = false;
  String? companyIDPath;
  bool _isPasswordVisible = false; // Password visibility toggle

  final List<String> workplaces = [
    "Mother Seton",
    "Our Lady of Lourdes Infirmary",
    // Add more workplace options here
  ];

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    lastnameController.dispose();
    firstnameController.dispose();
    specializationController.dispose();
  }

  String toTitleCase(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void pickCompanyID() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        companyIDPath = result.files.single.path!;
      });
    } else {
      showSnackBar(context, 'No file selected.');
    }
  }

  void signUpHealthCareProvider() async {
    if (selectedWorkplace == null) {
      showSnackBar(context, 'Please select a workplace.');
      return;
    }

    if (companyIDPath == null) {
      showSnackBar(context, 'Please upload your company ID.');
      return;
    }

    // Upload the company ID file to Firebase Storage
    String uploadedFileURL = await uploadCompanyID(companyIDPath!);

    String res = await AuthServices().signUpHealthCareProvider(
        email: emailController.text,
        password: passwordController.text,
        lastname: toTitleCase(lastnameController.text),
        firstname: toTitleCase(firstnameController.text),
        workplace: selectedWorkplace!,
        companyIDPath: uploadedFileURL, // Pass the uploaded file URL
        specialization: specializationController.text);

    if (res == "Success") {
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ProviderVerificationStatusScreen(),
      ));
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final padding = mediaQuery.padding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - padding.top - padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Sign up | salud.ko",
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 50),
                InputTextField(
                  textEditingController: firstnameController,
                  hintText: "Enter first name",
                  icon: Icons.person_3_rounded,
                ),
                InputTextField(
                  textEditingController: lastnameController,
                  hintText: "Enter last name",
                  icon: Icons.person_3_rounded,
                ),
                InputTextField(
                  textEditingController: emailController,
                  hintText: "Enter email",
                  icon: Icons.email_rounded,
                ),
                InputTextField(
                  textEditingController: passwordController,
                  hintText: "Enter password",
                  isPass: !_isPasswordVisible, // Toggle visibility
                  icon: Icons.lock_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                InputTextField(
                  textEditingController: specializationController,
                  hintText: "Enter specialization (e.g. Cardiology)",
                  icon: Icons.work_outline_rounded,
                ),
                WorkplaceDropdown(
                  selectedWorkplace: selectedWorkplace,
                  workplaces: workplaces,
                  onChanged: (newValue) {
                    setState(() {
                      selectedWorkplace = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: pickCompanyID,
                  icon: const Icon(Icons.upload_file),
                  label: Text(companyIDPath == null
                      ? "Upload Company ID"
                      : "ID Uploaded"),
                ),
                const SizedBox(height: 20),
                MyButton(onTab: signUpHealthCareProvider, text: "Sign Up"),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyLogin(),
                            ));
                      },
                      child: const Text(
                        " Log In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String> uploadCompanyID(String filePath) async {
  final file = File(filePath);
  final fileName = file.path.split('/').last;

  final storageRef =
      FirebaseStorage.instance.ref().child('company_ids/$fileName');
  final uploadTask = storageRef.putFile(file);

  final snapshot = await uploadTask;
  return await snapshot.ref.getDownloadURL();
}
