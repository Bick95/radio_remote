import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential authResult =
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      final User user = authResult.user;
      return user;
    } catch(e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
      return user;
    } catch(e) {
      print(e.toString());
      return null;
    }

    Future resetPass(String email) async {
      try {
        return await _auth.sendPasswordResetEmail(email: email);
      } catch(e) {
        print(e.toString());
      }
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
    }
  }
}