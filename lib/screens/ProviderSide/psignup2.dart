import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:saludko/screens/ProviderSide/ProviderVerificationStatusPage.dart';
import 'package:saludko/screens/Services/authentication.dart';
import 'package:saludko/screens/widget/snackbar.dart';
import 'package:saludko/screens/widget/textfield.dart';
import 'package:saludko/screens/widget/workplacedropdown.dart';

class ProfessionalDetailsSignupPage extends StatefulWidget {
  const ProfessionalDetailsSignupPage({super.key});

  @override
  _ProfessionalDetailsSignupPageState createState() =>
      _ProfessionalDetailsSignupPageState();
}

String? selectedWorkplace;
bool isLoading = false;
String? companyIDPath;

final List<String> workplaces = [
    "Mother Seton",
    "Our Lady of Lourdes Infirmary",
    "Dr. Nilo O. Roa Memorial Foundation Hospital",
    "Madrid Dental Center",
    "M.E. Villegas Dental Clinic",
];

class _ProfessionalDetailsSignupPageState
    extends State<ProfessionalDetailsSignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController workplaceController = TextEditingController();
  final TextEditingController companyIdController = TextEditingController();

  bool isLoading = false;

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

    void saveProfessionalDetails() async {
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

    String res = await AuthServices().saveProfessionalDetails(
        workplace: selectedWorkplace!,
        companyIDPath: uploadedFileURL, // Pass the uploaded file URL
        specialization: toTitleCase(specializationController.text));

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
    return Scaffold(
      appBar: AppBar(title: const Text("Professional Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              label: Text(
                  companyIDPath == null ? "Upload Company ID" : "ID Uploaded"),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: saveProfessionalDetails,
                    child: const Text("Submit"),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    specializationController.dispose();
    workplaceController.dispose();
    companyIdController.dispose();
    super.dispose();
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
