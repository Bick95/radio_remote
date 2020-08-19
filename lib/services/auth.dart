import 'package:firebase_auth/firebase_auth.dart';
import 'package:radio_remote/model/user.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user) {
    /// CONDITION ? TRUE-CASE : FALSE-CASE
    return user != null ? User(user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      // await to wait for result to be returned
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);

    } catch(e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
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