import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/widgets/widget.dart';

class AddDevice extends StatefulWidget {
  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {

  AuthMethods authMethods = new AuthMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogout(context, authMethods),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white12,
        child: Text("TODO: enable adding devices..."),
      ),
    );
  }
}
