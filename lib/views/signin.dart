import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/views/device_list.dart';
import 'package:radio_remote/widgets/widget.dart';

// TODO: add "Remember me"-option

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
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isLoading = false;

  AuthMethods authMethods = new AuthMethods();

  final formKey = GlobalKey<FormState>();

  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  signMeIn(){
    if (formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });

      authMethods.signInWithEmailAndPassword(
          emailTextEditingController.text.trim(),
          passwordTextEditingController.text.trim()).then((val){
        print("Val::: $val");
        if (val != null && val.runtimeType == User){
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
