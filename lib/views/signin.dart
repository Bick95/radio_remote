import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/views/device_list.dart';
import 'package:radio_remote/widgets/widget.dart';

// TODO: add error message when login was unsuccessful

class SignIn extends StatefulWidget {

  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _readSaveStorage();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isLoading = false;

  AuthMethods authMethods = new AuthMethods();

  final _storage = FlutterSecureStorage();
  bool rememberMe = false;

  final formKey = GlobalKey<FormState>();

  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  signMeIn(){
    if (formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });

      String email = emailTextEditingController.text.trim();
      String password = passwordTextEditingController.text.trim();

      authMethods.signInWithEmailAndPassword(
          email,
          password).then((val){
        print("Val::: $val");
        if (val != null && val.runtimeType == User){
          // Save latest log in data if user wants to
          if (rememberMe){
            _storage.write(key: "username", value: email);
            _storage.write(key: "password", value: password);
          } else {
            // Erase what was (potentially) in storage
            _storage.write(key: "username", value: "");
            _storage.write(key: "password", value: "");
          }

          // Go to next page
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => DeviceList()
          ));  // Without going back option
        }
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<Null> _readSaveStorage() async {
    // Read in user's credentials if saved & insert it into TextFormFields
    try {
      final all = await _storage.readAll();
      setState(() {
        if (all.containsKey("username") && all.containsKey("password")){
          // Get stored credentials
          String email = all["username"];
          String password = all["password"];

          // Set credentials into respective text fields
          emailTextEditingController.text = email;
          passwordTextEditingController.text = password;

          if (email != "" && password != ""){
            rememberMe = true; // Data was stored, so default to do it again
          }
        }
      });
    } catch (exception) {
      print("No data safely stored? Exception: " + exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    ) : Scaffold(
      appBar: appBarMain(context),
      body: SingleChildScrollView  (
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: (val){
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-z]+").hasMatch(val) ? null : "Enter valid email!";
                    },
                    keyboardType: TextInputType.emailAddress,
                    controller: emailTextEditingController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("email"),
                  ),
                  TextFormField(
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (val){
                      return val.length >= 6 ? null : 'Provide stronger password!';
                    },
                    controller: passwordTextEditingController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("password"),
                    onFieldSubmitted: (value){
                      signMeIn();
                    },
                  ),
                  SizedBox(height: 8,), // Space
                  Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            //color: Colors.white,
                            alignment: Alignment.centerLeft,
                            child: Checkbox(
                              value: rememberMe,
                              checkColor: Colors.white,
                              activeColor: Colors.lightBlue,
                              focusColor: Colors.green,
                              hoverColor: Colors.red,
                              onChanged: (value){
                                print("Value: " + value.toString());
                                setState(() {
                                  rememberMe = value;
                                });
                              }
                            ),
                          ),
                          Text("Remember me.", style: simpleTextStyle(),),
                        ],
                      ),
                      SizedBox(width: 25,),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Forgot Password?", style: simpleTextStyle(),),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),
                  GestureDetector(
                    onTap: (){
                      signMeIn();
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
                      child: Text("Sign In", style: mediumTextStyle(),),
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
                    child: Text("Sign In with Google", style: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                    ),),
                  ),
                  SizedBox(height: 16,),          // Add some spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account? ", style: mediumTextStyle(),),  // TODO: continue...
                      GestureDetector(
                        onTap: () {
                          widget.toggle();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text("Register now!", style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            decoration: TextDecoration.underline
                          )
                            ,),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
