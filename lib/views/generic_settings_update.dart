import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/widgets/widget.dart';

class GenericSettingsUpdate extends StatefulWidget {

  DatabaseReference databaseReference;
  String header;

  GenericSettingsUpdate({@required this.databaseReference,
                         @required this.header});

  @override
  _GenericSettingsUpdateState createState() => _GenericSettingsUpdateState(databaseReference: databaseReference, header: header);
}

class _GenericSettingsUpdateState extends State<GenericSettingsUpdate> with SingleTickerProviderStateMixin {

  DatabaseReference databaseReference;
  String header;

  List settingsList = new List();

  _GenericSettingsUpdateState({@required this.databaseReference,
                               @required this.header});

  AnimationController _controller;

  AuthMethods authMethods = new AuthMethods();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();

    // TODO: add listeners for value changes
  }

  @override
  void dispose() {
    _controller.dispose();

    // TODO: cancle listeners

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Init data

    return Scaffold(
      appBar: appBarWithLogout(context, authMethods),
      body: // TODO: FutureBuilder: retrieve all data values & create list view inside future builder;
      Container(
        child: Column(
          children: [
            SizedBox(height: 16,),
            Container(
              child: Text(
                  header,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
              ),
            ),
            SizedBox(height: 16,),
            Container(
              child: Text(
                "Update one field & click \"Update\" to change a respective field. Else go back to discard changes.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 16,),
            Container(
              height: 500,
              child: FutureBuilder(
                future: databaseReference.once(),
                builder: (context, AsyncSnapshot<DataSnapshot> snapshot){
                  if (snapshot.hasData){
                    settingsList.clear();
                    Map<dynamic, dynamic> values = snapshot.data.value;
                    if (values != null){
                      values.forEach((key, value) {
                        settingsList.add(SettingsEditTile(keyName: key.toString(),
                          value: value.toString(), databaseReference: databaseReference,
                        )
                        );
                        print("Key: " + value.toString());
                        print("Value: " + key.toString());
                      });
                    }
                    return settingsList.isEmpty ? Container(
                      alignment: Alignment.center,
                      child: Text(
                        "No meta-settings available for this device.",
                        style: TextStyle(
                          color: Colors.white12,
                        ),
                      ),
                    ) :
                    new ListView.builder(
                      shrinkWrap: true,
                      itemCount: settingsList.length,
                      itemBuilder: (BuildContext context, int index){
                        return settingsList[index];
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
          ],
        ),
      ),
    );
  }
}


class SettingsEditTile extends StatelessWidget {

  final String keyName;
  String value;
  DatabaseReference databaseReference;
  TextEditingController textEditingController = new TextEditingController();

  SettingsEditTile({@required this.keyName,
                    @required this.value,
                    @required this.databaseReference});

  @override
  Widget build(BuildContext context) {
    textEditingController.text = value;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Container(
        padding: EdgeInsets.all(5),
        color: Colors.white12,
        child: Row(
          children: [
            Column( // Name and email
              children: [
                Container(
                    width: 200,
                    child: Text(keyName + ":", style: simpleTextStyle(),)
                ),
                Container(
                  width: 200,
                  child: TextField(
                    keyboardType: TextInputType.name,
                    controller: textEditingController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("value"),
                  ),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                print("Tapped " + keyName + ".");
                var map;
                try {
                  int text = int.parse(textEditingController.text);
                  map = {
                    keyName: text,
                  };
                } catch (exception) {
                  String text = textEditingController.text;
                  map = {
                    keyName: text,
                  };
                }
                databaseReference.update(map);
              },
              child: Container( // 'Msg button'
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Update"),
              ),
            )
          ],
        ),
      ),
    );
  }
}