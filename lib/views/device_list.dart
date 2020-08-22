import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/services/database.dart';
import 'package:radio_remote/views/add_device.dart';
import 'package:radio_remote/views/radio_control.dart';
import 'package:radio_remote/widgets/widget.dart';

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List deviceList = new List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogout(context, authMethods),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddDevice()
          ));
        },
      ),
      body: Container(
        child: FutureBuilder(
          future: FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("device_list").once(),
          builder: (context, AsyncSnapshot<DataSnapshot> snapshot){
            if (snapshot.hasData){
              deviceList.clear();
              Map<dynamic, dynamic> values = snapshot.data.value;
              if (values != null){
                values.forEach((key, value) {
                  deviceList.add(DeviceTile(deviceName: value["name"].toString(),
                    deviceType: value["type"].toString(),
                    deviceId: key.toString(),
                  )
                  );
                  print("Value: " + value.toString());
                  print("Key: " + key.toString());
                });
              }
              return deviceList.isEmpty ? Container(
                alignment: Alignment.center,
                child: Text(
                  "No devices registered yet.",
                  style: TextStyle(
                    color: Colors.white12,
                  ),
                ),
              ) :
              new ListView.builder(
                shrinkWrap: true,
                itemCount: deviceList.length,
                itemBuilder: (BuildContext context, int index){
                   return deviceList[index];
                },
              );
            }
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class DeviceTile extends StatelessWidget {

  final String deviceName;
  final String deviceType;
  final String deviceId;

  DeviceTile({this.deviceName, this.deviceType, this.deviceId});

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
                Text("Name: " + deviceName, style: simpleTextStyle(),),
                Text("Type: " + deviceType, style: simpleTextStyle(),),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                print("Tapped " + deviceName + ".");
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => RadioControl(deviceId: deviceId) // TODO: make switch statement to choose between different device type views based on deviceType
                ));
              },
              child: Container( // 'Msg button'
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Control"),
              ),
            )
          ],
        ),
      ),
    );
  }
}