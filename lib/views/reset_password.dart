import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/widgets/widget.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  bool isLoading;

  final formKey = GlobalKey<FormState>();

  TextEditingController textEditingController = new TextEditingController();

  var auth = FirebaseAuth.instance;

  String displayText;
  Color textColor;

  sendResetPasswordEmail(String email) {

    setState(() {
      isLoading = true;
    });

    if (formKey.currentState.validate()) {
      setState(() {
        auth.sendPasswordResetEmail(email: email).then((value) {
          // Sent.
          setState(() {
            displayText = "Sent.";
            textColor = Colors.white;
          });
        }).catchError((error) {
          setState(() {
            // Error.
            displayText = "Error message: " + error.toString();
            textColor = Colors.red;
          });
        });
      });
    } else {
      setState(() {
        displayText = null;
        textColor = Colors.red;
      });
    }

    setState(() {
      isLoading = false;
    });

  }


  Container textualFeedback(
                            String text,
                            {double fontSize = 16,
                             Color textColor = Colors.red}
                           ){
    return Container(
      width: MediaQuery.of(context).size.width-20,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: 16,),
        ],
      ),
    );
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    displayText = null;
    isLoading = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    ) :
    Scaffold(
      appBar: appBarMain(context),
      body: Column(
        children: [
          SizedBox(height: 16,),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              "Reset Password",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Enter email address and click \"Submit\" to request a new password via an email sent to the provided email address.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: TextFormField(
                validator: (input){
                  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-z]+").hasMatch(input) ? null : "Enter valid email!";
                },
                keyboardType: TextInputType.emailAddress,
                controller: textEditingController,
                style: simpleTextStyle(),
                decoration: textFieldInputDecoration("email"),
                onFieldSubmitted: (val){
                  print("Submit button pressed: " + val.toString());
                  sendResetPasswordEmail(val.trim());
                },
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          displayText != null ? textualFeedback(displayText, textColor: textColor) : Container(),
          FlatButton(
            onPressed: (){
              print("Pressed submit email!");
              sendResetPasswordEmail(textEditingController.text.trim());
            },
            color: Colors.blue,
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
