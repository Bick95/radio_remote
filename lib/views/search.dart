import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:radio_remote/services/database.dart';
import 'package:radio_remote/widgets/widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
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

  TextEditingController searchTextEditingController = new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  QuerySnapshot searchSnapshot;

  initiateSearch(){
    print("Initiate search...");
    databaseMethods.getUserByUsername(searchTextEditingController.text).then((val){
      print(val.toString());
      setState(() { // Set state updates full page upon execution
        searchSnapshot = val;
      });
    });
  }

  /*
  Widget searchList(){
    print("Search list!");
    print((searchSnapshot == null).toString());
    print(searchSnapshot != null ? searchSnapshot.documents.length.toString() : "Nulllll");

    return searchSnapshot != null ? ListView.builder(
      shrinkWrap: true,  // IMPORTANT!
      itemCount: searchSnapshot.documents.length,
      itemBuilder: (context, index){  // Function that populates ListView
        return SearchTile(
          userName: searchSnapshot.documents[index].data['name'],
          userEmail: searchSnapshot.documents[index].data['email'],
        );
      },
    ) : Container(
      // Empty container...
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(  // Search bar
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        style: TextStyle(
                          // Text style for input text
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "Input & search user name",
                          hintStyle: TextStyle(
                            // Text style for hint text
                            color: Colors.white54
                          ),
                          border: InputBorder.none
                        ),
                      )),
                  GestureDetector(
                    onTap: (){
                      initiateSearch();
                      print("Press detected!");
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.search,
                          color: Colors.amber,
                        )
                    ),
                  )
                ],
              ),
            ),
            /*searchList()*/null,
          ],
        ),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {

  final String userName;
  final String userEmail;

  SearchTile({this.userName, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Column( // Name and email
            children: [
              Text(userName, style: simpleTextStyle(),),
              Text(userEmail, style: simpleTextStyle(),),
            ],
          ),
          Spacer(),
          Container( // 'Msg button'
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Message"),
          )
        ],
      ),
    );
  }
}
