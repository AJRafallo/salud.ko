import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to validate the password policy
  bool isPasswordValid(String password) {
    // Example policy: At least 8 characters, including upper/lowercase, digit, and special character
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  // Forgot Password Method
  Future<String> resetPassword(String email) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: email);
        res = "Password reset email sent. Please check your inbox.";
      } else {
        res = "Please provide an email address.";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          firstname.isNotEmpty &&
          lastname.isNotEmpty) {
        if (!isPasswordValid(password)) {
          return "Password must be at least 8 characters long and include uppercase, lowercase, a number, and a special character.";
        }

        // Create user and send email verification
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user!.sendEmailVerification();

        // Save user data to Firestore
        await _firestore.collection("users").doc(credential.user!.uid).set({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'uid': credential.user!.uid,
          'role': 'user',
        });

        res = "Check your email for verification";
      } else {
        res = "Please fill all the fields";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

    Future<String> signUpHealthCareProvider1({
    required String email,
    required String password,
    required String firstname,
    required String lastname,

  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          firstname.isNotEmpty &&
          lastname.isNotEmpty) {
        if (!isPasswordValid(password)) {
          return "Password must be at least 8 characters long and include uppercase, lowercase, a number, and a special character.";
        }

        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore
            .collection("healthcare_providers")
            .doc(credential.user!.uid)
            .set({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'uid': credential.user!.uid,
          'role': 'healthcare_provider',
          'isVerified': false,
        });

        res = "Success";
      } else {
        res = "Please fill all the fields";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

Future<String> saveProfessionalDetails({
  required String workplace,
    required String companyIDPath,
    required String specialization,



  }) async {
    User? user = _auth.currentUser;
    String res = "Some error occurred";
    try {
      if (workplace.isNotEmpty &&
          companyIDPath.isNotEmpty &&
          specialization.isNotEmpty) {

        await _firestore
            .collection("healthcare_providers")
            .doc(user!.uid)
            .set({
          'workplace': workplace,
          'companyIDPath': companyIDPath,
          'specialization':specialization,
        }, SetOptions(merge: true));

        res = "Success";
      } else {
        res = "Please fill all the fields";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<String> signUpHealthCareProvider({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String workplace,
    required String companyIDPath,
    required String specialization,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          firstname.isNotEmpty &&
          lastname.isNotEmpty &&
          workplace.isNotEmpty &&
          companyIDPath.isNotEmpty &&
          specialization.isNotEmpty) {
        if (!isPasswordValid(password)) {
          return "Password must be at least 8 characters long and include uppercase, lowercase, a number, and a special character.";
        }

        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore
            .collection("healthcare_providers")
            .doc(credential.user!.uid)
            .set({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'uid': credential.user!.uid,
          'role': 'healthcare_provider',
          'isVerified': false,
          'workplace': workplace,
          'companyIDPath': companyIDPath,
          'specialization': specialization
        });

        res = "Success";
      } else {
        res = "Please fill all the fields";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  

  Future<String> logInUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        /*if (!isPasswordValid(password)) {
          return "Password must be at least 8 characters long and include uppercase, lowercase, a number, and a special character.";
        }*/

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        String uid = userCredential.user!.uid;

        // Check if the user is a healthcare provider
        DocumentSnapshot providerDoc =
            await _firestore.collection('healthcare_providers').doc(uid).get();

        if (providerDoc.exists) {
          bool isVerified = providerDoc.get('isVerified');
          if (isVerified) {
            res = "healthcare_provider";
          } else {
            res =
                "not_verified"; // Indicates that the account is not yet verified
          }
        }
        // If not a healthcare provider, check if the user is a regular user
        else {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists) {
            res = "user";
          }
          // If not a regular user, check if the user is an admin
          else {
            DocumentSnapshot adminDoc =
                await _firestore.collection('admins').doc(uid).get();
            if (adminDoc.exists) {
              res = "admin";
            }
            // Check if the user is a hospital admin
            else {
              DocumentSnapshot hospitalDoc =
                  await _firestore.collection('hospital').doc(uid).get();
              if (hospitalDoc.exists) {
                res = "hospital_admin";
              } else {
                res = "User not found in any role collection.";
              }
            }
          }
        }
      } else {
        res = "Please enter all the fields";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) return;
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return userDoc['name'];
      } else {
        throw Exception('User data not found');
      }
    } else {
      throw Exception('No user logged in');
    }
  }
}
