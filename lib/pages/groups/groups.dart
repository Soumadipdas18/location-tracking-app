import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locationtracker/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Groups extends StatefulWidget {
  final String username;
  const Groups({Key? key,required this.username}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> with WidgetsBindingObserver {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final String uid;
  late final User user;
String username="souma18";
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> cs = FirebaseFirestore.instance
        .collection('groups')
        .where('users', arrayContains: username)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a group"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: cs,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.connectionState == ConnectionState.active) {
              var groupdata = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: groupdata.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 4.0),
                        child: Card(
                            child: ListTile(
                              onTap: () {},
                              title: Text(groupdata[index]['groupname'],style: TextStyle(fontWeight: FontWeight.bold,),textScaleFactor: 1.4,),
                              subtitle:Text(groupdata[index]['users'].join(','),maxLines: 1,) ,
                            ),
                          ),

                        );
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, SEARCH),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    user = auth.currentUser;
    uid = user.uid;
  }
  // void listtostring(List list){
  //   String sentence="";
  //   list.forEach((element) {
  //     sentence=sentence+element+",";
  //   });
  //   sentence
  // }

}
