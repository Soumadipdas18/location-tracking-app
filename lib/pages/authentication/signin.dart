import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locationtracker/constants/constants.dart';
import 'package:locationtracker/helpers/sharedpref.dart';
import 'package:locationtracker/models/custom_shape.dart';
import 'package:locationtracker/models/responsive_ui.dart';
import 'package:locationtracker/pages/groups/home.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({Key? key, required this.title, required this.isDark})
      : super(key: key);
  final String title;
  final bool isDark;

  @override
  _SigninpageState createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  double? _height;
  double? _width;
  double? _pixelRatio;
  bool _large = false;
  bool _medium = false;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width!, _pixelRatio!);
    _medium = ResponsiveWidget.isScreenMedium(_width!, _pixelRatio!);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: _height,
          child: Column(
            children: [
              PreferredSize(
                child: clipShape(),
                preferredSize: Size(_width!, _height! / 3),
              ),
              Spacer(),
              Forms(isDark: widget.isDark),
              Spacer(),
            ],
          ),
        ),
      ),
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
                'assets/images/login.png',
                width: _width! / 3.5,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                'SIGN IN',
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
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
        )
      ],
    );
  }
}

class Forms extends StatefulWidget {
  const Forms({Key? key, required this.isDark}) : super(key: key);
  final bool isDark;

  @override
  _FormsState createState() => _FormsState();
}

class _FormsState extends State<Forms> {
  double? _height;
  double? _width;
  double? _pixelRatio;
  bool _large = false;
  bool _medium = false;
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  sharedpref sf = new sharedpref();
  bool _isloading = false;
  final keys = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width!, _pixelRatio!);
    _medium = ResponsiveWidget.isScreenMedium(_width!, _pixelRatio!);
    return _isloading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
          )
        : Form(
            key: keys,
            child: Container(
              padding: EdgeInsets.all(15.0),
              child: (Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Enter your email",
                        labelText: "Email",
                        icon: Icon(Icons.email)),
                    validator: (value) {
                      return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!)
                          ? null
                          : "Please Enter Correct Email";
                    },
                    controller: emailEditingController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Enter your password",
                        labelText: "Password",
                        icon: Icon(Icons.lock)),
                    validator: (value) {
                      return value!.length > 6
                          ? null
                          : "Enter Password 6+ characters";
                    },
                    controller: passwordEditingController,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                            child: Text(
                          "Forgot Password?",
                        )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 12,
                  ),
                  RaisedButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    onPressed: () {
                      signIn();
                    },
                    textColor: Colors.white,
                    padding: EdgeInsets.all(0.0),
                    child: Container(
                      alignment: Alignment.center,
                      width: _large
                          ? _width! / 3.5
                          : (_medium ? _width! / 3.25 : _width! / 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        gradient: LinearGradient(
                          colors: <Color>[Colors.blue[200]!, Colors.blueAccent],
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Text('SIGN IN',
                          style: TextStyle(
                              fontSize: _large ? 14 : (_medium ? 12 : 10))),
                    ),
                  ),
                ],
              )),
            ));
  }

  signIn() async {
    if (keys.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailEditingController.text,
                password: passwordEditingController.text);
        await addshared_pref();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          coolalertfailure('No user found for that email.');
          setState(() {
            _isloading = false;
          });
        } else if (e.code == 'wrong-password') {
          coolalertfailure('Wrong password provided for that user.');
          setState(() {
            _isloading = false;
          });
        } else {
          coolalertfailure('Error $e');
          setState(() {
            _isloading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isloading = false;
        });
        print(e);
      }
    }
  }

  Future<void> addshared_pref() async {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: emailEditingController.text)
        .get()
        .then((snapshot) async {
      snapshot.docs.forEach((element) async {
        await sf.saveUsername(element['name']);

        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                      username: element['name'],
                      isDark: widget.isDark,
                    )));
        coolalertsuccess('Logged in successfully');
        setState(() {
          _isloading = false;
        });
      });
    });
  }

  coolalertsuccess(String text) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      title: 'Congratulations',
      text: text,
      loopAnimation: false,
    );
  }

  coolalertfailure(String text) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      title: 'Oops...',
      text: text,
      loopAnimation: false,
    );
  }
}
