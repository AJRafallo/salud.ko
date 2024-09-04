import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String name}) async {
    String res = " Some error occured";
    try {

    if(email.isNotEmpty || password.isNotEmpty || name.isNotEmpty){
    UserCredential credential =
            await _auth.createUserWithEmailAndPassword(
              email: email, 
              password: password);

            await _firestore.collection("users").doc(credential.user!.uid).set({
              'name': name,
              'email': email,
              'uid': credential.user!.uid,
              'role': 'user',
            });
            res = "Success";
    }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<String> signUpHealthCareProvider(
      {required String email,
      required String password,
      required String name,}) async {
    String res = " Some error occured";
    try {

    if(email.isNotEmpty || password.isNotEmpty || name.isNotEmpty){
    UserCredential credential =
            await _auth.createUserWithEmailAndPassword(
              email: email, 
              password: password);

            await _firestore.collection("healthcare_providers").doc(credential.user!.uid).set({
              'name': name,
              'email': email,
              'uid': credential.user!.uid,
              'role': 'healthcare_provider',
              'isVerified': false,
            });
            res = "Success";
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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      DocumentSnapshot providerDoc = await _firestore.collection('healthcare_providers').doc(uid).get();

      if (providerDoc.exists) {
        bool isVerified = providerDoc.get('isVerified');
        if (isVerified) {
          res = "healthcare_provider";
        } else {
          res = "not_verified";  // Indicates that the account is not yet verified
        }
      } else {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          res = "user";
        } else {
          DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(uid).get();
          if (adminDoc.exists) {
            res = "admin";
          } else {
            res = "User not found in any role collection.";
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




  Future<void> signOut() async{
    await _auth.signOut();
  }


/* Future<String> logInUser({
    required String email,
    required String password,
  }) async{
        String res = " Some error occured";
    try{
        if(email.isNotEmpty || password.isNotEmpty){
          await _auth.signInWithEmailAndPassword(
            email: email, 
            password: password);
            res = "success"; 
        }
        else{
            res = "Please enter all the field";
        }
    } catch(e){
      return e.toString();
    }
    return res;
  }

  Future<String> logInHealthcareProvider({
    required String email,
    required String password,
  }) async{
        String res = " Some error occured";
    try{
        if(email.isNotEmpty || password.isNotEmpty){
          await _auth.signInWithEmailAndPassword(
            email: email, 
            password: password);
            res = "success"; 
        }
        else{
            res = "Please enter all the field";
        }
    } catch(e){
      return e.toString();
    }
    return res;
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }

*/

  Future<String> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

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


