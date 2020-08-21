import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/widgets/widget.dart';

class AddRadioStation extends StatefulWidget {
  @override
  _AddRadioStationState createState() => _AddRadioStationState();
}

class _AddRadioStationState extends State<AddRadioStation> {

  AuthMethods authMethods = new AuthMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogout(context, authMethods),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white12,
        child: Text("TODO: enable adding & REMOVING(!!!) radio stations..."),
      ),
    );
  }
}
