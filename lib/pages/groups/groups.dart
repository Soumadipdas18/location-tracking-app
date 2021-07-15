import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:location/location.dart';
import 'package:locationtracker/models/custom_shape.dart';
import 'package:locationtracker/models/responsive_ui.dart';
import 'package:locationtracker/pages/authentication/editableprofile.dart';
import 'package:locationtracker/pages/groups/search.dart';
import 'package:locationtracker/pages/info/aboutus.dart';
import 'package:locationtracker/pages/info/help.dart';
import 'package:locationtracker/pages/maps/map.dart';
import 'package:locationtracker/pages/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Groups extends StatefulWidget {
  final String username;
  final bool isDark;

  const Groups({Key? key, required this.username, required this.isDark})
      : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> with WidgetsBindingObserver {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final String uid;
  late final User user;
  bool _isloading = false;
  Location location = Location();
  List<GlobalKey<ExpansionTileCardState>> expansionkeys = [];
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  TextEditingController _textfieldcontroller = new TextEditingController();
  bool large = false;
  bool medium = false;
  double? _height;
  double? _width;
  double? _pixelRatio;
  bool _large = false;
  bool _medium = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  trygetlocation(String username, List users, String grpid) async {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.confirm,
        text: 'Do you want to share your location',
        confirmBtnText: 'Yes',
        onConfirmBtnTap: () async {
          Navigator.of(context).pop();
          setState(() {
            _isloading = true;
          });
          getLoc(username, users, grpid);
        },
        cancelBtnText: 'No',
        onCancelBtnTap: () async {
          Navigator.of(context).pop();
        },
        confirmBtnColor: ThemeData().accentColor);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    user = auth.currentUser!;
    uid = user.uid;
  }

  getLoc(String username, List users, String grpid) async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _isloading = false;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isloading = false;
        });
        return;
      }
    }
    LocationData _currentPosition;
    _currentPosition = await location.getLocation();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => MyLocation(
                username: username,
                users: users,
                userid: uid,
                grpid: grpid,
                userlat: _currentPosition.latitude!,
                userlong: _currentPosition.longitude!,
                isDark: widget.isDark,
              )),
    );
    setState(
      () {
        _isloading = false;
      },
    );
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
                setState(() {
                  _isloading = true;
                });
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
    setState(
      () {
        _isloading = false;
      },
    );
  }

  Widget clipShape() {
    //double height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large
                  ? _height! / 4
                  : (_medium ? _height! / 3.75 : _height! / 3.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    !widget.isDark
                        ? ThemeData().accentColor
                        : Color(0xff6d6666),
                    !widget.isDark
                        ? ThemeData().primaryColor
                        : Color(0xff000000)
                  ],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _large
                  ? _height! / 4.5
                  : (_medium ? _height! / 4.25 : _height! / 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    !widget.isDark
                        ? ThemeData().accentColor
                        : Color(0xff868181),
                    !widget.isDark
                        ? ThemeData().primaryColor
                        : Color(0xff474646)
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(
              top: _large
                  ? _height! / 30
                  : (_medium ? _height! / 25 : _height! / 20)),
          height: _height! / 3.5,
          width: _width!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/mapicon.png',
                width: _width! / 3.5,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                'GROUPS',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _large ? 40 : (_medium ? 30 : 20),
                    letterSpacing: 3.0),
              ),
              SizedBox(
                height: 5.0,
              ),
            ],
          ),
        ),
        SafeArea(
          child: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
          ),
        )
      ],
    );
  }

  logout() async {
    setState(() {
      _isloading = true;
    });
    FirebaseAuth.instance.signOut();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    setState(() {
      _isloading = false;
    });
    Phoenix.rebirth(context);
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width!, _pixelRatio!);
    _medium = ResponsiveWidget.isScreenMedium(_width!, _pixelRatio!);
    print("${widget.username} received");
    Stream<QuerySnapshot> cs = FirebaseFirestore.instance
        .collection('groups')
        .where('users', arrayContains: widget.username)
        .snapshots();
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        child: clipShape(),
        preferredSize: Size(_width!, _height! / 3),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(widget.username),
                accountEmail: Text(user.email!),
                currentAccountPicture: Image.asset('assets/images/login.png'),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Home"),
                  onTap: () {},
                ),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Settings"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Settingspage(
                              username: widget.username, useruid: uid)),
                    );
                  },
                ),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("My Profile"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => EditProfilePage(
                            username: widget.username, isDark: widget.isDark),
                      ),
                    );
                  },
                ),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.help),
                  title: Text("Help"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              Help(isDark: widget.isDark)),
                    );
                  },
                ),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text("About us"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              Aboutus(isDark: widget.isDark)),
                    );
                  },
                ),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Log Out"),
                  onTap: () {
                    Navigator.pop(context);
                    CoolAlert.show(
                        context: context,
                        type: CoolAlertType.confirm,
                        text: 'Do you want to log out?',
                        confirmBtnText: 'Yes',
                        onConfirmBtnTap: () {
                          logout();
                        },
                        cancelBtnText: 'No',
                        onCancelBtnTap: () async {
                          Navigator.of(context).pop();
                        },
                        confirmBtnColor: ThemeData().accentColor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isloading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: cs,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  var groupdata = snapshot.data!.docs;
                  if (groupdata.length != 0) {
                    return ListView.builder(
                      itemCount: groupdata.length,
                      itemBuilder: (context, index) {
                        GlobalKey<ExpansionTileCardState> key = new GlobalKey();
                        expansionkeys.insert(expansionkeys.length, key);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 4.0),
                          child: ExpansionTileCard(
                            baseColor: widget.isDark
                                ? Color(0xff333338)
                                : Colors.cyan[50],
                            expandedTextColor: Colors.blue,
                            expandedColor: widget.isDark
                                ? Color(0xff333338)
                                : Colors.red[50],
                            key: expansionkeys[index],
                            title: Text(
                              groupdata[index]['groupname'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              groupdata[index]['users'].join(','),
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
                                  child: Text(
                                    'All members- ${groupdata[index]['users'].join(',')}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(fontSize: 16),
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
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                    onPressed: () {
                                      trygetlocation(
                                          widget.username,
                                          groupdata[index]['users'],
                                          groupdata[index].id);
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Icon(Icons.location_searching_outlined),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Text('Track'),
                                        Text('Location'),
                                      ],
                                    ),
                                  ),
                                  FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                    onPressed: () {
                                      if (groupdata[index]['owner'] ==
                                          widget.username) {}
                                      if (groupdata[index]['owner'] !=
                                          widget.username) {
                                        CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.confirm,
                                            text: 'Want to leave the group',
                                            confirmBtnText: 'Yes',
                                            onConfirmBtnTap: () {
                                              List users =
                                                  groupdata[index]['users'];
                                              users.remove(widget.username);
                                              FirebaseFirestore.instance
                                                  .collection('groups')
                                                  .doc(groupdata[index].id)
                                                  .update(
                                                {'users': users},
                                              );
                                              Navigator.of(context).pop();
                                            },
                                            cancelBtnText: 'No',
                                            onCancelBtnTap: () async {
                                              Navigator.of(context).pop();
                                            },
                                            confirmBtnColor:
                                                ThemeData().accentColor);
                                      }
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        if (groupdata[index]['owner'] ==
                                            widget.username)
                                          Icon(Icons.delete),
                                        if (groupdata[index]['owner'] !=
                                            widget.username)
                                          Icon(Icons.logout),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        if (groupdata[index]['owner'] ==
                                            widget.username)
                                          Text('Delete'),
                                        if (groupdata[index]['owner'] !=
                                            widget.username)
                                          Text('Leave'),
                                        Text('Group'),
                                      ],
                                    ),
                                  ),
                                  if (groupdata[index]['owner'] ==
                                      widget.username)
                                    FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0)),
                                      onPressed: () {
                                        addmem(
                                            context,
                                            groupdata[index]['users'],
                                            groupdata[index].id);
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Icon(Icons.add_box_outlined),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
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
                  return Center(child: CircularProgressIndicator());
                }
              }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Search(
                    username: widget.username,
                    isDark: widget.isDark,
                  )),
        ),
      ),
    );
  }
}
