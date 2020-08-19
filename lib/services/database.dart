import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  getUserByUsername(String userName) async {
    return await Firestore.instance.collection("users").where("name", isEqualTo: userName).getDocuments();
  }

  bool uploadUserInfo(userMap){
    var success = true;
    Firestore.instance.collection("users").add(userMap).catchError((e){
      print("### EXCEPTION when uploading user info: ###");
      print(e.toString());
      success = false;  // Normally, user authentication would have to be deleted in this case again (as well)
    });
    return success;  // False in case of exception
  }
}