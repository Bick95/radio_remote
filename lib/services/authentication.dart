
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationMethods {
  getCurrentUsersID() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    return user.uid;
  }
}