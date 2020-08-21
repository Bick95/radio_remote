
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationMethods {
  getCurrentUsersID() {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    return user.uid;
  }
}