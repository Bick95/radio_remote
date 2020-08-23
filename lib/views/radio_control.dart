import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/services/database.dart';
import 'package:radio_remote/widgets/widget.dart';
import 'manage_radio_stations.dart';


class RadioControl extends StatefulWidget {
  // Constructor
  const RadioControl({
    @required this.deviceId
  }) : super();

  final String deviceId;

  @override
  _RadioControlState createState() => _RadioControlState(deviceId: deviceId);
}

class _RadioControlState extends State<RadioControl> with SingleTickerProviderStateMixin {
  // Constructor
  _RadioControlState({
    @required this.deviceId
  });

  AnimationController _controller;

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  TextEditingController volTextEditingController = new TextEditingController();

  StreamSubscription<Event> streamSubscriptionState;
  StreamSubscription<Event> streamSubscriptionVol;
  StreamSubscription<Event> streamSubscriptionStation;

  Color backGroundColor = Colors.orange;

  bool circular = true;

  // Device values
  final String deviceId;
  String deviceType = "Radio";
  String deviceName;
  String screenHeader;
  String currentStation;
  int deviceVol;
  int deviceState;
  Color stateColor;

  toggleShape(){
    setState(() {
      circular = !circular;
    });
  }

  setDeviceName(String name){
    setState(() {
      deviceName = name;
      screenHeader = deviceName + ", " + deviceType;
    });
  }

  setDeviceType(String type){
    setState(() {
      deviceType = type;
      screenHeader = deviceName + ", " + deviceType;
    });
  }

  setStation(String name){
    setState(() {
      currentStation = name;
      print("Setting device state: " + name);
    });
  }

  setDeviceVol(int vol){
    setState(() {
      deviceVol = vol;
      volTextEditingController.text = deviceVol.toString();
    });
  }

  setDeviceState(int state){
    setState(() {
      deviceState = state;
      if (deviceState > 0){
        stateColor = Colors.lightGreen;
      } else {
        stateColor = Colors.redAccent;
      }
    });
  }

  BoxShape returnCurrentBoxShape(){
    if (circular){
      return BoxShape.circle;
    }
    return BoxShape.rectangle;
  }

  @override
  Future<void> initState() {
    _controller = AnimationController(vsync: this);

    super.initState();

    // Listener for Device State
    streamSubscriptionState = FirebaseDatabase.instance.reference().child("users").
    child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).child("settings").child("state").onValue.listen((event) {
      setDeviceState(event.snapshot.value);
    });

    // Listener for Device Volume
    streamSubscriptionVol = FirebaseDatabase.instance.reference().child("users").
    child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).child("settings").child("vol").onValue.listen((event) {
      setDeviceVol(event.snapshot.value);
    });

    // Listener for Device Volume
    streamSubscriptionStation = FirebaseDatabase.instance.reference().child("users").
    child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).child("radio_info").child("current_station").onValue.listen((event) {
      setStation(event.snapshot.value);
    });

  }

  // Methods for database manipulation

  turnOnOff(){
    FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).child("settings").once().then((value) {
      print("Retrieved value: " + value.toString());
      if (value != null) {
        // Observe current settings
        DataSnapshot snapshot = value as DataSnapshot;
        int state = snapshot.value["state"] as int;
        print("Retrieved state: " + state.toString());

        // Calculate updated volume
        int newState = ((state == 0) ? 1 : 0);
        print("New state: " + newState.toString());
        // Update new setting in database
        var map = {
          "state": newState,
        };
        FirebaseDatabase.instance.reference().child("users").child(
            FirebaseAuth.instance.currentUser.uid).child("devices").child(
            deviceId).child("settings").update(map);
        print("Submitted.");
      }
    });
  }

  updateFirebaseVol(bool increaseVol){
    FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).once().then((value) {
      print("Retrieved value: " + value.toString());
      if (value != null) {
        // Observe current settings
        DataSnapshot snapshot = value as DataSnapshot;
        int volChange = snapshot.value["meta_info"]["vol_change"] as int;
        print("Vol-change: " + volChange.toString());
        int currVol = snapshot.value["settings"]["vol"] as int;
        print("Current vol: " + currVol.toString());
        // Calculate updated volume
        int newVol = increaseVol ? currVol + volChange : currVol - volChange;
        print("New vol: " + newVol.toString());
        // Update new setting in database
        var map = {
          "vol": newVol,
        };
        FirebaseDatabase.instance.reference().child("users").child(
            FirebaseAuth.instance.currentUser.uid).child("devices").child(
            deviceId).child("settings").update(map);
        print("Submitted.");
      }
    });
  }

  updateFirebaseVolManually(int value){
    FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).once().then((snapshot) {
      print("Retrieved value: " + value.toString());
      if (value != null) {
        // Observe current settings
        int volChange = snapshot.value["meta_info"]["vol_change"] as int;
        print("Vol-change: " + volChange.toString());
        int currVol = snapshot.value["settings"]["vol"] as int;
        print("Current vol: " + currVol.toString());

        // Set sensible bounds on manual user input
        if (value < 0) {
          value = 0;  // Lower bound
        } else if (value > currVol + 5 * volChange) {
          value = currVol + 5 * volChange;
        }


        // Update new setting in database
        var map = {
          "vol": value,
        };
        FirebaseDatabase.instance.reference().child("users").child(
            FirebaseAuth.instance.currentUser.uid).child("devices").child(
            deviceId).child("settings").update(map);
        print("Submitted.");
      }
    });

  }

  updateFirebaseStation(bool increaseStation){
    FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).once().then((snapshot) {
      FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("radio_stations").once().then((stations) {
        print("Retrieved value: " + snapshot.value.toString());

        if (snapshot != null && stations != null) {

          /// PART 1 - Update station id (=index)///
          // Observe number of stations
          int numStations = stations.value.length;
          print("Num stations object: " + stations.value.toString());
          print("Num stations: " + numStations.toString());

          // Observe current settings
          int currStation = snapshot.value["settings"]["current_station_id"] as int;
          print("CurrStation: " + currStation.toString());

          // Calculate new station id
          int newStation = (increaseStation ? (currStation +1) : currStation -1);
          print("New station prior: " + newStation.toString());
          // Make sure not to go out of bounds
          if (newStation >= numStations){
            newStation = 0;
          } else if (newStation < 0){
            newStation = numStations -1;
          }
          print("New station: " + newStation.toString());

          // Update new setting in database
          var map = {
            "current_station_id": newStation,
          };
          FirebaseDatabase.instance.reference().child("users").child(
              FirebaseAuth.instance.currentUser.uid).child("devices").child(
              deviceId).child("settings").update(map);


          /// PART 2 - Update station key for later station name retrieval, based on above index ///
          // TODO: pack sorting with respect to keys into query
          // Compute ordered list of available radio stations and their keys
          var list = [];
          Map<dynamic, dynamic> values = stations.value;
          values.forEach((key, value) {
            print(""); print("key: " + key.toString()); print("val: " + value.toString());
            list.add({"key": key.toString(), "value": value,
            });
          });
          list.sort(
              (a, b){
                return a["key"].compareTo(b["key"]);
              }
          );
          print("Sorted List: " + list.toString());

          // Compute name of new station key & name
          String newStationKey = list[newStation]["key"].toString();
          String newStationName = list[newStation]["value"]["name"].toString();

          // Update new setting in database
          map.clear();
          var map2 = {
            "current_station_key": newStationKey,
            "current_station": newStationName,
          };
          FirebaseDatabase.instance.reference().child("users").child(
              FirebaseAuth.instance.currentUser.uid).child("devices").child(
              deviceId).child("radio_info").update(map2);

          print("Submitted.");
        }
      });
    });
  }

  @override
  void dispose() {
    print("+++++ Disposing... +++++");
    _controller.dispose();
    streamSubscriptionStation.cancel().then((value) {
      streamSubscriptionState.cancel().then((value) {
        streamSubscriptionVol.cancel().then((value) {
          print("Done cancelling.");
        });
      });
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference ref = FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).child("meta_info");
    return Scaffold(
      appBar: appBarWithLogoutSettings(context, authMethods, ref, "Update Device Settings"),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.book),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ManageRadioStations(),
          ));
        },
      ),
      body:
          FutureBuilder(
            future: FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("devices").child(deviceId).once(),
            builder: (context, AsyncSnapshot<DataSnapshot> snapshot){
              if (snapshot.hasData){
                // Set fields
                print("Retrieved data: " + snapshot.data.value.toString());
                deviceType = snapshot.data.value["meta_info"]["type"];
                deviceName = snapshot.data.value["meta_info"]["name"];
                screenHeader = deviceName + ", " + deviceType;
                currentStation = snapshot.data.value["radio_info"]["current_station"];
                deviceVol = snapshot.data.value["settings"]["vol"];
                volTextEditingController.text = deviceVol.toString();
                deviceState = snapshot.data.value["settings"]["state"];
                stateColor = deviceState == 1 ? Colors.greenAccent : Colors.redAccent;

                ////// +++ ########## +++ START UI +++ ########## +++ //////
                return SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          // Device info
                          children: [
                            Container(
                              height: 44,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              color: backGroundColor,
                              child: Text(
                                screenHeader,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          // ##### Volume bar #####
                          color: backGroundColor,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: stateColor,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally
                                crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically
                                children: [
                                  Container(
                                    //padding: EdgeInsets.only(bottom: 7),
                                    child: Text(
                                      "Vol: ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // Container to make sure text field is on same height as text "Vol:"
                                    // Also shifts input curser position, unfortunately...
                                    //padding: EdgeInsets.only(top: 8), //23
                                    child: SizedBox(
                                      height: 20,
                                      width: 40,
                                      child: TextFormField(
                                        onFieldSubmitted: (value){
                                          print("The value entered is : $value");
                                          updateFirebaseVolManually(int.parse(value));
                                        },
                                        // Define keyboard type
                                        keyboardType: TextInputType.number,
                                        // Make sure user doesn't enter letters or punctuation
                                        inputFormatters: <TextInputFormatter>[
                                          WhitelistingTextInputFormatter.digitsOnly
                                        ],
                                        validator: (val){
                                          return null;
                                        },
                                        controller: volTextEditingController,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          // Circle element
                          height: MediaQuery.of(context).size.height - 54 - 88 - 24,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height - 54 - 88 - 24)/7.0,
                          color: backGroundColor,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  toggleShape();
                                },
                                child: Container(
                                  // ##### CIRCLE #####
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: returnCurrentBoxShape(),
                                    color: Colors.redAccent, // orange, redAccent, tealAccent
                                  ),
                                  child: Column(
                                    // ##### Column inside circle #####
                                    children: [
                                      Container(
                                        // ##### Top row of circle: Vol up #####
                                        height: 220/3,
                                        child: GestureDetector(
                                          onTap: (){
                                            print("Volume up!!!");
                                            updateFirebaseVol(true);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white10,
                                            ),
                                            child: Icon(
                                              Icons.add,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        // ##### Middle row of circle #####
                                        height: 220/3,
                                        child: Row(
                                          children: [
                                            Container(
                                              // ##### Arrow left: previous station #####
                                              width: 220/3,
                                              child: GestureDetector(
                                                onTap: (){
                                                  print("Previous station...");
                                                  updateFirebaseStation(false);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white10,
                                                  ),
                                                  child: Icon(
                                                    Icons.arrow_left,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              // ##### Start/Stop music #####
                                              width: 220/3,
                                              child: GestureDetector(
                                                onTap: (){
                                                  print("Start/Stop music.");
                                                  turnOnOff();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white10,
                                                  ),
                                                  child: Icon(
                                                    Icons.audiotrack,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              // ##### Arrow right: next station #####
                                              width: 220/3,
                                              child: GestureDetector(
                                                onTap: (){
                                                  print("Next station...");
                                                  updateFirebaseStation(true);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white10,
                                                  ),
                                                  child: Icon(
                                                    Icons.arrow_right,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        // ##### Bottom Row of circle #####
                                        height: 220/3,
                                        child: GestureDetector(
                                          onTap: (){
                                            print("Volume down!");
                                            updateFirebaseVol(false);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white10,
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width - 50,
                                  margin: const EdgeInsets.all(30.0),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blueGrey)
                                  ),
                                  child: Text(
                                    currentStation,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
              ////// +++ ########## +++ END UI +++ ########## +++ //////
              }  else if (snapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.white12,
                  child: Text("Something went wrong."),
                );
              }
              return Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator());
            },
          ),

    );
  }
}
