import 'package:firebase_auth/firebase_auth.dart';
import 'package:radio_remote/model/user.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CustomUser _userFromFirebaseUser(FirebaseUser user) {
    /// CONDITION ? TRUE-CASE : FALSE-CASE
    return user != null ? CustomUser(user.uid) : null;
  }

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
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
      return user;
    } catch(e) {
      print(e.toString());
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