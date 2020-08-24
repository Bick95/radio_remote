import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/widgets/widget.dart';

class RemoveRadioStation extends StatefulWidget {
  @override
  _RemoveRadioStationState createState() => _RemoveRadioStationState();
}

class _RemoveRadioStationState extends State<RemoveRadioStation> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  List stationsList = new List();

  AuthMethods authMethods = new AuthMethods();

  StreamSubscription streamSubscriptionStationsList;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();

    // Listener for Device State
    streamSubscriptionStationsList = FirebaseDatabase.instance.reference().child("users").
    child(FirebaseAuth.instance.currentUser.uid).child("radio_stations").onValue.listen((event) {
      setState(() {
        // pass
      });
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    streamSubscriptionStationsList.cancel().then((value) {
      print("Stream canceled!");
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogout(context, authMethods),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 16,),
                Center(
                  child: Text(
                    "Remove Radio Stations",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 150,
                  ),
                  child: FutureBuilder(
                    future: FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("radio_stations").once(),
                    builder: (context, AsyncSnapshot<DataSnapshot> snapshot){
                      if (snapshot.hasData){
                        // Construct list of list tiles
                        stationsList.clear();

                        Map<dynamic, dynamic> values = snapshot.data.value;

                        if (values != null){
                          values.forEach((key, value) {
                            stationsList.add(RadioStationRemovalTile(
                                stationName: value["name"].toString(),
                                stationUrl: value["url"].toString(),
                                stationId: key.toString(),
                              )
                            );
                            print("Value: " + value.toString());
                            print("Key: " + key.toString());
                          });
                        }
                        return stationsList.isEmpty ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            "No stations present yet.",
                            style: TextStyle(
                              color: Colors.white12,
                            ),
                          ),
                        ) :
                        new ListView.builder(
                            shrinkWrap: true,
                            itemCount: stationsList.length,
                            itemBuilder: (BuildContext context, int index){
                              return stationsList[index];
                            },
                        );

                        // Construct list view
                      }

                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class RadioStationRemovalTile extends StatelessWidget {

  final String stationName;
  final String stationUrl;
  final String stationId;

  RadioStationRemovalTile({this.stationName, this.stationUrl, this.stationId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Container(
        padding: EdgeInsets.all(5),
        color: Colors.white12,
        child: Row(
          children: [
            Column( // Name and email
              children: [
                Text("Name: " + stationName, style: simpleTextStyle(),),
                Text("Url: " + stationUrl, style: simpleTextStyle(),),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                print("Tapped " + stationName + ".");
                FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("radio_stations").child(stationId).remove().then((value) {
                  print("Removed...");
                });
              },
              child: Container( // 'Msg button'
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Remove"),
              ),
            )
          ],
        ),
      ),
    );
  }
}