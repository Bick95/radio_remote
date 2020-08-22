import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/services/database.dart';
import 'package:radio_remote/views/chat_room_screen.dart';
import 'package:radio_remote/widgets/widget.dart';

import 'device_list.dart';

class SignUp extends StatefulWidget {

  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isLoading = false;
  String _error = null;

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formKey = GlobalKey<FormState>();

  TextEditingController userNameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  signMeUp(){

    String userEmail = emailTextEditingController.text.trim();
    String userName = userNameTextEditingController.text.trim();
    String userPassword = passwordTextEditingController.text.trim();
    print(userEmail);
    print(userName);
    print(userPassword);

    // TODO: upload
    Map<String, String> userInfoMap = {
      // Create map as long as text fields are shown to the user (i.e. before changing screen)
      "name": userName,
      "email": userEmail,
    };

    if (formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });

      // Check whether email is registered already
      FirebaseAuth.instance.fetchSignInMethodsForEmail(emailTextEditingController.text).catchError((error1){
        print("Error (1): " + error1.toString());
        _error = error1.toString();
      }).then((result) {

        print("<><> Result: " + result.runtimeType.toString() + ", " + result.toString());

        if (result.runtimeType == (List<String>()).runtimeType && result.isEmpty){

          //////////////////////////////////////
          authMethods.signUpWithEmailAndPassword(
              userEmail,
              userPassword).catchError((error2){
                print("Error (2): " + error2.toString());
                _error = error2.toString();
          }).then((val){

                print("Val: " + val.toString());

                if (val != null && val.runtimeType == User){
                  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => DeviceList()
                  ));  // Without going back option
                } else {
                  print("####### ERROR #######");
                  _error = val.toString();
                }
            });
          /////////////////////////////////////

        } else if (result.runtimeType == (List<String>()).runtimeType && result.isNotEmpty){
          _error = "Email is already registered.";
        } else {
          _error = "Some unspecified error occurred. Check inputs for correctness.";
        }
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading ? Container(
        child: Center(child: CircularProgressIndicator()),
      ) : SingleChildScrollView  (
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (val){
                          return val.isEmpty || val.length < 1 ? "Provide user name with at least 1 character." : null;
                        },
                        keyboardType: TextInputType.name,
                        controller: userNameTextEditingController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("username"),
                      ),
                      TextFormField(
                        validator: (val){
                          return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-z]+").hasMatch(val) ? null : "Enter correct email!";
                        },
                        keyboardType: TextInputType.emailAddress,
                        controller: emailTextEditingController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("email"),
                      ),
                      TextFormField(
                        obscureText: true,
                        validator: (val){
                          return val.length >= 6 ? null : 'Provide stronger password!';
                        },
                        keyboardType: TextInputType.visiblePassword,
                        controller: passwordTextEditingController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("password"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8,), // Space
                Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Forgot Password?", style: simpleTextStyle(),),
                  ),
                ),
                SizedBox(height: 16,),
                Container(
                  child: _error != null ? Text(
                    "Error: " + _error,
                    style: TextStyle(
                      color: Colors.red,

                    ),
                  ) : Container(),
                ),
                SizedBox(height: 16,),
                GestureDetector(
                  onTap: (){
                    signMeUp();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,         // Get screen size
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            const Color(0xff007EF4),
                            const Color(0xff2A75BC),
                          ]
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text("Sign Up", style: mediumTextStyle(),),
                  ),
                ),
                SizedBox(height: 16,),          // Add some spacing
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,         // Get screen size
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text("Sign Up with Google", style: TextStyle(
                    color: Colors.black87,
                    fontSize: 17,
                  ),),
                ),
                SizedBox(height: 16,),          // Add some spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have account? ", style: mediumTextStyle(),),  // TODO: continue...
                    GestureDetector(
                      onTap: () {
                        widget.toggle();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Sign In now!", style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        decoration: TextDecoration.underline
                    )
                      ,),
                      )
                    )
                  ],
                ),
                SizedBox(height: 50,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
