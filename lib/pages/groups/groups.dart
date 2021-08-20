import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locationtracker/pages/groups/search.dart';
import 'package:locationtracker/pages/groups/singlegrouptile.dart';

class Groups extends StatefulWidget {
  final String username;
  final bool isDark;

  const Groups({Key? key, required this.username, required this.isDark})
      : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  List<GlobalKey<ExpansionTileCardState>> expansionkeys = [];
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  bool _isloading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final String uid;
  late final User user;
  double? _width;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser!;
    uid = user.uid;
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    Stream<QuerySnapshot> cs = FirebaseFirestore.instance
        .collection('groups')
        .where('users', arrayContains: widget.username)
        .snapshots();
    return Scaffold(
      body: _isloading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: cs,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  List<QueryDocumentSnapshot<Object?>> groupdata =
                      snapshot.data!.docs;
                  if (groupdata.length != 0) {
                    return ListView.builder(
                      itemCount: groupdata.length,
                      itemBuilder: (context, index) {
                        GlobalKey<ExpansionTileCardState> key = new GlobalKey();
                        expansionkeys.insert(expansionkeys.length, key);
                        return SingleGroupTile(
                            username: widget.username,
                            isDark: widget.isDark,
                            expansionkeys: expansionkeys,
                            groupdata: groupdata,
                            index: index,
                            uid: uid);
                      },
                    );
                  } else {
                    return Center(
                      child: Container(
                        padding: EdgeInsets.all(_width! / 20),
                        child: Text(
                            "Create a group by clicking on the '+' button",
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "Create a Group",
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Search(
              username: widget.username,
              isDark: widget.isDark,
            ),
          ),
        ),
      ),
    );
  }
}
