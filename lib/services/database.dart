import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  /*
  addNewUser() async {

    // Test-wise
    firestore.collection("users").add(
        {
          "name" : "john",
          "age" : 50,
          "email" : "example@example.com",
          "address" : {
            "street" : "street 24",
            "city" : "new york"
          }
        }).then((value){
      print(value.documentID);
    });

  }
  */

  getUserByUsername(String userName) async {
    return await firestore.collection("users").where("name", isEqualTo: userName).getDocuments();
  }

  bool uploadUserInfo(userMap){
    var success = true;
    firestore.collection("users").add(userMap).catchError((e){
      print("### EXCEPTION when uploading user info: ###");
      print(e.toString());
      success = false;  // Normally, user authentication would have to be deleted in this case again (as well)
    });
    return success;  // False in case of exception
  }

  getUserData() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    print(firebaseUser.uid);
    return firestore.collection("users").document(firebaseUser.uid).get().then((value){
      print(value.data);
      return value.data;
    });
  }

}