import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:radio_remote/services/auth.dart';

class DatabaseMethods {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //Firestore firestore = Firestore.instance;
  FirebaseDatabase firebaseDB = new FirebaseDatabase();

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

  getDB() {
    return FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid);
  }

  getUserByUsername(String userName) {
    //return await firebaseDB.
    //return await firestore.collection("users").where("name", isEqualTo: userName).getDocuments();
    var userData = FirebaseDatabase.instance.reference().child('users').child(userName);
    return userData;
  }

  getUserData() {
    FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).once().then((DataSnapshot data){
      print("Values: " + data.value.toString());
      print("Keys: " + data.key.toString());
      return data;
    });
  }

  getDeviceData(String deviceName) async {
    var data;
    FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("devices").orderByChild("name").equalTo(deviceName).once().then((DataSnapshot data){
      print("Device data: " + data.value.toString());
      data = data.value;
    });
    return data;
  }
  
  /*
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
    var firebaseUser = FirebaseAuth.instance.currentUser;
    print(firebaseUser.uid);
    return firestore.collection("users").document(firebaseUser.uid).get().then((value){
      print(value.data);
      return value.data;
    });
  }*/

}