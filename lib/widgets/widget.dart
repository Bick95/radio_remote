import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/helper/authenticate.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/views/generic_settings_update.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Image.asset("assets/images/db_radio_remote.jpg", height: 50,),
    toolbarHeight: 54,
  );
}

Widget appBarWithLogout(BuildContext context, AuthMethods authMethods) {
  return AppBar(
    toolbarHeight: 54,
    title: Image.asset("assets/images/db_radio_remote.jpg", height: 50,),
    actions: [
      GestureDetector(
        onTap: (){
          authMethods.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => Authenticate()
          ));
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.exit_to_app)),
      ),
    ],
  );
}

Widget appBarWithLogoutSettings(BuildContext context, AuthMethods authMethods, DatabaseReference ref, String header) {
  return AppBar(
    toolbarHeight: 54,
    title: Image.asset("assets/images/db_radio_remote.jpg", height: 50,),
    actions: [
      GestureDetector(
        onTap: (){
          print("Settings...");
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => GenericSettingsUpdate(databaseReference: ref, header: header)
          ));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.settings),
        ),
      ),
      GestureDetector(
        onTap: (){
          authMethods.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => Authenticate()
          ));
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.exit_to_app)),
      ),
    ],
  );
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
          color: Colors.white54
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: Colors.white),
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white
          )
      )
  );
}

TextStyle simpleTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 16,
  );
}

TextStyle mediumTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 17,
  );
}
