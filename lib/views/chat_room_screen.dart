import 'package:flutter/material.dart';
import 'package:radio_remote/helper/authenticate.dart';
import 'package:radio_remote/services/auth.dart';
import 'package:radio_remote/views/radio_control.dart';
import 'package:radio_remote/views/search.dart';
import 'package:radio_remote/widgets/widget.dart';

import 'device_list.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with SingleTickerProviderStateMixin {
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            //builder: (context) => SearchScreen()
            builder: (context) => DeviceList()//RadioControl(deviceName: "RadioControl",),
          ));
        },
      ),
    );
  }
}
