import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/views/add_radio_station.dart';
import 'package:radio_remote/views/remove_radio_station.dart';
import 'package:radio_remote/widgets/widget.dart';

class ManageRadioStations extends StatefulWidget {
  @override
  _ManageRadioStationsState createState() => _ManageRadioStationsState();
}

class _ManageRadioStationsState extends State<ManageRadioStations> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  AuthMethods authMethods = new AuthMethods();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogout(context, authMethods),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Text(
              "Manage Radio Stations",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16,),
            Center(
              child: RaisedButton(
                child: Text("Add station"),
                onPressed: (){
                  print("Add station.");
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AddRadioStation()
                  ));
                },
              ),
            ),
            SizedBox(height: 16,),
            Center(
              child: RaisedButton(
                child: Text("Remove station"),
                onPressed: (){
                  print("Remove station.");
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => RemoveRadioStation()
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
