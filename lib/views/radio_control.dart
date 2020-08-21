import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/services/database.dart';
import 'package:radio_remote/views/add_radio_station.dart';
import 'package:radio_remote/widgets/widget.dart';

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

    //databaseMethods.addNewUser();
    
    //var data = databaseMethods.getUserData();
    /*.then((value){
      print("Val: " + value.data.toString());
      print("Val: " + value.data["devices"].toString());
    });
    print("Returned: " + data.toString());*/

    // Get user data
    databaseMethods.getUserData()/*.then((value){
        print("User Values: " + value.toString());
      }
    )*/;
    var value = databaseMethods.getDeviceData(deviceId);
    print("+++ Returned value: " + value.toString());

    // Set database values
    deviceName = "Raspi";
    deviceType = "Radio";
    screenHeader = "Raspi, Radio";
    currentStation = "Radio HH";
    deviceVol = 80;
    deviceState = 0;
    stateColor = Colors.redAccent;
    volTextEditingController.text = deviceVol.toString();

    // Set listeners/callbacks for updating states

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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.book),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            //builder: (context) => SearchScreen()
            builder: (context) => AddRadioStation(),
          ));
        },
      ),
      body: SingleChildScrollView(
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
              child: Container(
                height: 44,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: stateColor,
                ),
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
                    /*Text("160",
                      // TODO: turn into text field for direct editing
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),*/
                    Container(
                      // Container to make sure text field is on same height as text "Vol:"
                      // Also shifts input curser position, unfortunately...
                      //padding: EdgeInsets.only(top: 8), //23
                      child: SizedBox(
                        height: 20,
                        width: 40,
                        child: TextFormField(
                          onFieldSubmitted: (value){
                            // https://www.geeksforgeeks.org/retrieve-data-from-textfields-in-flutter/
                            print("The value entered is : $value");
                          },
                          // Define keyboard type
                          keyboardType: TextInputType.number,
                          // Make sure user doesn't enter letters or punctuation
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          validator: (val){
                            return null; //RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-z]+").hasMatch(val) ? null : "Enter correct email!";
                          },
                          //autofocus: true,
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
      ),
    );
  }
}
