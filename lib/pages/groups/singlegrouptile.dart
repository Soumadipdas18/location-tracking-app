import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:location/location.dart';
import 'package:locationtracker/pages/groupchats/groupchat.dart';
import 'package:locationtracker/pages/maps/map.dart';

class SingleGroupTile extends StatefulWidget {
  final bool isDark;
  final String username, uid;
  final List expansionkeys;
  final List<QueryDocumentSnapshot<Object?>> groupdata;
  final int index;

  const SingleGroupTile(
      {Key? key,
      required this.username,
      required this.isDark,
      required this.expansionkeys,
      required this.groupdata,
      required this.index,
      required this.uid})
      : super(key: key);

  @override
  _SingleGroupTileState createState() => _SingleGroupTileState();
}

class _SingleGroupTileState extends State<SingleGroupTile> {
  bool _isloading = false;
  Location location = Location();
  TextEditingController _textfieldcontroller = new TextEditingController();
  List<bool> hide = [];

  @override
  void initState() {
    hide = List.filled(widget.groupdata.length, false);
  }

  Future<void> addmem(BuildContext context, List users, String id) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter username of user'),
          content: TextField(
            controller: _textfieldcontroller,
            decoration: InputDecoration(hintText: "Username"),
          ),
          actions: <Widget>[
            // add button
            ElevatedButton(
              child: Text('SEARCH'),
              onPressed: () async {
                Navigator.of(context).pop();
                // setState(() {
                //   _isloading = true;
                // });
                await FirebaseFirestore.instance
                    .collection('users')
                    .where('name', isEqualTo: _textfieldcontroller.text)
                    .get()
                    .then(
                  (snapshot) {
                    setState(
                      () {
                        if (snapshot.docs.length != 0) {
                          snapshot.docs.forEach(
                            (element) {
                              if (!users.contains(element['name'])) {
                                users.insert(users.length, element['name']);
                                FirebaseFirestore.instance
                                    .collection('groups')
                                    .doc(id)
                                    .update(
                                  {'users': users},
                                );
                                coolalertaddmem(
                                    "Member Added Successfully", false);
                              } else {
                                coolalertaddmem("User Already Exists", true);
                              }
                            },
                          );
                        } else {
                          coolalertaddmem("Member not found", true);
                        }
                      },
                    );
                  },
                );
              },
            ),
            // Cancel button
            ElevatedButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
                _textfieldcontroller.clear();
              },
            ),
          ],
        );
      },
    );
  }

  coolalertaddmem(String text, bool iserror) {
    CoolAlert.show(
      context: context,
      type: iserror ? CoolAlertType.error : CoolAlertType.success,
      title: iserror ? 'Oops...' : 'Success',
      text: text,
      loopAnimation: false,
    );
    _textfieldcontroller.clear();
    // setState(
    //   () {
    //     _isloading = false;
    //   },
    // );
  }

  trygetlocation(String username, List users, String grpid) async {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.confirm,
        text: 'Do you want to share your location',
        confirmBtnText: 'Yes',
        onConfirmBtnTap: () async {
          Navigator.of(context).pop();
          EasyLoading.show();
          getLoc(username, users, grpid);
        },
        cancelBtnText: 'No',
        onCancelBtnTap: () async {
          Navigator.of(context).pop();
        },
        confirmBtnColor: ThemeData().accentColor);
  }

  getLoc(String username, List users, String grpid) async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        EasyLoading.dismiss();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        EasyLoading.dismiss();
        return;
      }
    }
    LocationData _currentPosition;
    _currentPosition = await location.getLocation();
    EasyLoading.dismiss();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => MyLocation(
                username: username,
                users: users,
                userid: widget.uid,
                grpid: grpid,
                userlat: _currentPosition.latitude!,
                userlong: _currentPosition.longitude!,
                isDark: widget.isDark,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
      child: ExpansionTileCard(
        baseColor: widget.isDark ? Color(0xff333338) : Colors.cyan[50],
        expandedTextColor: Colors.blue,
        expandedColor: widget.isDark ? Color(0xff333338) : Colors.red[50],
        key: widget.expansionkeys[widget.index],
        title: Text(
          widget.groupdata[widget.index]['groupname'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          widget.groupdata[widget.index]['users'].join(', '),
          maxLines: 1,
        ),
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'All members- ',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(
                        text:
                            widget.groupdata[widget.index]['users'].join(', ')),
                  ],
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            buttonHeight: 52.0,
            buttonMinWidth: 90.0,
            children: <Widget>[
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                onPressed: () {
                  trygetlocation(
                      widget.username,
                      widget.groupdata[widget.index]['users'],
                      widget.groupdata[widget.index].id);
                },
                child: Column(
                  children: <Widget>[
                    Icon(Icons.location_searching_outlined),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Text('Track'),
                    Text('Location'),
                  ],
                ),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => GroupChat(
                            username: widget.username,
                            users: widget.groupdata[widget.index]['users'],
                            // userid: widget.uid,
                            grpid: widget.groupdata[widget.index].id,
                            // userlat: _currentPosition.latitude!,
                            // userlong: _currentPosition.longitude!,
                            isDark: widget.isDark,
                            groupname: widget.groupdata[widget.index]
                                ['groupname'])),
                  );
                },
                child: Column(
                  children: <Widget>[
                    Icon(Icons.message_outlined),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Text('Group'),
                    Text('Chat'),
                  ],
                ),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                onPressed: () {
                  setState(() {
                    hide[widget.index] = !hide[widget.index];
                  });
                },
                child: Column(
                  children: <Widget>[
                    Icon(Icons.settings),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    !hide[widget.index] ? Text('Other') : Text('Hide'),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
          if (hide[widget.index])
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              buttonHeight: 52.0,
              buttonMinWidth: 90.0,
              children: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  onPressed: () {
                    if (widget.groupdata[widget.index]['owner'] ==
                        widget.username) {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.confirm,
                          text: 'Want to delete the group',
                          confirmBtnText: 'Yes',
                          onConfirmBtnTap: () {
                            FirebaseFirestore.instance
                                .collection('groups')
                                .doc(widget.groupdata[widget.index].id)
                                .delete();
                            Navigator.of(context).pop();
                          },
                          cancelBtnText: 'No',
                          onCancelBtnTap: () async {
                            Navigator.of(context).pop();
                          },
                          confirmBtnColor: ThemeData().accentColor);
                    }
                    if (widget.groupdata[widget.index]['owner'] !=
                        widget.username) {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.confirm,
                          text: 'Want to leave the group',
                          confirmBtnText: 'Yes',
                          onConfirmBtnTap: () {
                            List users =
                                widget.groupdata[widget.index]['users'];
                            users.remove(widget.username);
                            FirebaseFirestore.instance
                                .collection('groups')
                                .doc(widget.groupdata[widget.index].id)
                                .update(
                              {'users': users},
                            );
                            Navigator.of(context).pop();
                          },
                          cancelBtnText: 'No',
                          onCancelBtnTap: () async {
                            Navigator.of(context).pop();
                          },
                          confirmBtnColor: ThemeData().accentColor);
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      if (widget.groupdata[widget.index]['owner'] ==
                          widget.username)
                        Icon(Icons.delete),
                      if (widget.groupdata[widget.index]['owner'] !=
                          widget.username)
                        Icon(Icons.logout),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      if (widget.groupdata[widget.index]['owner'] ==
                          widget.username)
                        Text('Delete'),
                      if (widget.groupdata[widget.index]['owner'] !=
                          widget.username)
                        Text('Leave'),
                      Text('Group'),
                    ],
                  ),
                ),
                if (widget.groupdata[widget.index]['owner'] == widget.username)
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    onPressed: () {
                      addmem(context, widget.groupdata[widget.index]['users'],
                          widget.groupdata[widget.index].id);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.add_box_outlined),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Add'),
                        Text('Members'),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
