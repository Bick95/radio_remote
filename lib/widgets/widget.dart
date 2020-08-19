import 'package:flutter/material.dart';
import 'package:radio_remote/helper/authenticate.dart';
import 'package:radio_remote/services/auth.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Image.asset("assets/images/db_chat.jpg", height: 50,),
    toolbarHeight: 54,
  );
}

Widget appBarWithLogout(BuildContext context, AuthMethods authMethods) {
  return AppBar(
    toolbarHeight: 54,
    title: Image.asset("assets/images/db_chat.jpg", height: 50,),
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
