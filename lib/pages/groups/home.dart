import 'package:cool_alert/cool_alert.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locationtracker/models/custom_shape.dart';
import 'package:locationtracker/models/responsive_ui.dart';
import 'package:locationtracker/pages/authentication/editableprofile.dart';
import 'package:locationtracker/pages/groups/groups.dart';
import 'package:locationtracker/pages/info/aboutus.dart';
import 'package:locationtracker/pages/info/help.dart';
import 'package:locationtracker/helpers/sharedpref.dart';

class Home extends StatefulWidget {
  final String username;
  final bool isDark;

  const Home({Key? key, required this.username, required this.isDark})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final String uid;
  late final User user;
  bool _isloading = false;
  bool large = false;
  bool medium = false;
  double? _height;
  double? _width;
  double? _pixelRatio;
  bool _large = false;
  bool _medium = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _selectedindex = 0;
  List title = ["GROUPS", "MY PROFILE", "HELP", "ABOUT US"];
  sharedpref _sf = new sharedpref();

  @override
  void initState() {
    super.initState();
    user = auth.currentUser!;
    uid = user.uid;
  }

  Widget clipShape() {
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
                title[_selectedindex],
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

  switchdarktheme(bool isSwitched) async {
    setState(() {
      isSwitched = !isSwitched;
    });
    await _sf.saveIsDakEnabled(isSwitched);
    Phoenix.rebirth(context);
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width!, _pixelRatio!);
    _medium = ResponsiveWidget.isScreenMedium(_width!, _pixelRatio!);
    bool isSwitched = widget.isDark;
    List pages = [
      Groups(username: widget.username, isDark: widget.isDark),
      EditProfilePage(username: widget.username, isDark: widget.isDark),
      Help(isDark: widget.isDark),
      Aboutus(isDark: widget.isDark)
    ];
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
                  leading: Icon(Icons.people_alt),
                  title: Text("Groups"),
                  onTap: () {
                    setState(() {
                      _selectedindex != 0 ? _selectedindex = 0 : null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("My Profile"),
                  onTap: () {
                    setState(() {
                      _selectedindex != 1 ? _selectedindex = 1 : null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.help),
                  title: Text("Help"),
                  onTap: () {
                    setState(() {
                      _selectedindex != 2 ? _selectedindex = 2 : null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text("About us"),
                  onTap: () {
                    setState(() {
                      _selectedindex != 3 ? _selectedindex = 3 : null;
                    });
                    Navigator.pop(context);
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
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.wallpaper),
                  title: Text("Dark Mode"),
                  onTap: () {
                    switchdarktheme(isSwitched);
                  },
                  trailing: DayNightSwitcherIcon(
                    isDarkModeEnabled: isSwitched,
                    onStateChanged: (k) {
                      switchdarktheme(isSwitched);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isloading
          ? Center(child: CircularProgressIndicator())
          : pages[_selectedindex],
    );
  }
}
