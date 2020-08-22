import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/widgets/widget.dart';

class AddRadioStation extends StatefulWidget {
  @override
  _AddRadioStationState createState() => _AddRadioStationState();
}

class _AddRadioStationState extends State<AddRadioStation> {

  AuthMethods authMethods = new AuthMethods();
  final formKey = GlobalKey<FormState>();

  bool loading = false;

  TextEditingController nameTextEditingController = new TextEditingController();
  TextEditingController urlTextEditingController = new TextEditingController();

  addStation(){
    if (formKey.currentState.validate()){

      var map = { // Get data before changing to loading, thereby making data inaccessible
        "name": nameTextEditingController.text.trim(),
        "url": urlTextEditingController.text.trim(),
      };

      setState(() {
        loading = true;
      });

      FirebaseDatabase.instance.reference().child("users").child(
          FirebaseAuth.instance.currentUser.uid).child("radio_stations").push().set(map).timeout(Duration(seconds: 10)).catchError((exception){
            if (exception.runtimeType == TimeoutException){
              print("Timeout!");
            }
            setState(() {
              loading = false;
            });
      }).then((value) {

          setState(() {
            loading = false;
          });
            nameTextEditingController.text = "";
            urlTextEditingController.text = "";
            print("Added.");
      });
      print("Submitted.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return loading ? Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ) : Scaffold(
      appBar: appBarWithLogout(context, authMethods),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              SizedBox(height: 16,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    "Add radio station name and link, then click on \"Submit\" or go back to cancel.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextFormField(
                          validator: (val){
                            return val.length > 0 ? null : "Enter radio station name.";
                          },
                          style: simpleTextStyle(),
                          controller: nameTextEditingController,
                          decoration: textFieldInputDecoration("radio station name"),
                        ),
                      ),
                    ),
                    SizedBox(height: 8,),
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextFormField(
                          validator: (val){
                            return val.length > 0 ? null : "Enter radio station url.";
                          },
                          style: simpleTextStyle(),
                          controller: urlTextEditingController,
                          decoration: textFieldInputDecoration("radio station url"),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32,),
              Center(
                child: RaisedButton(
                  onPressed: (){
                    print("Button pressed.");
                    addStation();
                  },
                  child: Text("Add"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
