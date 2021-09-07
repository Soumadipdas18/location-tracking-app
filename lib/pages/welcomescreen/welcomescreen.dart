import 'dart:math';
import 'package:flutter/material.dart';
import 'package:locationtracker/constants/constants.dart';
import 'package:locationtracker/helpers/sharedpref.dart';
import 'package:flutter/animation.dart';
import 'package:locationtracker/pages/groups/home.dart';
import 'package:locationtracker/pages/welcomescreen/AnimatedBubble.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key, required this.isDark}) : super(key: key);
  final bool isDark;

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late double _scaleSignin;
  late double _scaleSignup;
  bool _isloading = true;
  bool _routeLayout = false;
  late String _username;
  sharedpref _sf = new sharedpref();
  late Animation<double> backgroundAnimation;
  late AnimationController _backgroundController;
  late AnimationController _buttonControllerSignin;
  late AnimationController _buttonControllerSignup;
  final bubbleWidgets = <Widget>[];
  bool areBubblesAdded = false;
  late Animation<double> bubbleAnimation;
  late AnimationController bubbleController;
  AlignmentTween alignmentTop =
      AlignmentTween(begin: Alignment.topRight, end: Alignment.topLeft);
  AlignmentTween alignmentBottom =
      AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft);
  Animatable<Color?> backgroundDark = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.blue[800],
        end: Colors.pink[800],
      ),
    ),
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.pink[800],
        end: Colors.blue[800],
      ),
    ),
  ]);

// Normal color
  Animatable<Color?> backgroundNormal = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.blue[500],
        end: Colors.pink[500],
      ),
    ),
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.pink[500],
        end: Colors.blue[500],
      ),
    ),
  ]);

// Light color
  Animatable<Color?> backgroundLight = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.blue[200],
        end: Colors.pink[200],
      ),
    ),
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.pink[200],
        end: Colors.blue[200],
      ),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    _scaleSignin = 1 - _buttonControllerSignin.value;
    _scaleSignup = 1 - _buttonControllerSignup.value;
    if (!areBubblesAdded) {
      addBubbles(animation: bubbleAnimation);
    }
    return _isloading
        ? Center(child: CircularProgressIndicator())
        : AnimatedBuilder(
            animation: backgroundAnimation,
            builder: (context, child) {
              return Scaffold(
                body: Stack(
                    children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin:
                                    alignmentTop.evaluate(backgroundAnimation),
                                end: alignmentBottom
                                    .evaluate(backgroundAnimation),
                                colors: [
                                  backgroundDark.evaluate(backgroundAnimation)!,
                                  backgroundNormal
                                      .evaluate(backgroundAnimation)!,
                                  backgroundLight
                                      .evaluate(backgroundAnimation)!,
                                ],
                              ),
                            ),
                          ),
                        ] +
                        bubbleWidgets +
                        [
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Spacer(),
                                  Spacer(),
                                  Spacer(),
                                  Image.asset(
                                    'assets/images/welcomescreenlogo.png',
                                    width: 250,
                                    height: 250,
                                  ),
                                  Spacer(),
                                  Text("LIVE LOCATION TRACKING APP",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Spacer(),
                                  Spacer(),
                                  Spacer(),
                                  Spacer(),
                                  Container(
                                    child: !_routeLayout
                                        ? GestureDetector(
                                            onTapDown: _onTapDownSignin,
                                            onTapUp: _onTapUpSignin,
                                            child: Transform.scale(
                                              scale: _scaleSignin,
                                              child:
                                                  _animatedButtonUI("Sign In"),
                                            ),
                                          )
                                        : null,
                                  ),
                                  Spacer(),
                                  Container(
                                    child: !_routeLayout
                                        ? GestureDetector(
                                            onTapDown: _onTapDownSignup,
                                            onTapUp: _onTapUpSignup,
                                            child: Transform.scale(
                                              scale: _scaleSignup,
                                              child:
                                                  _animatedButtonUI("Register"),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTapDown: _onTapDownSignup,
                                            onTapUp: _onTapUpSignup,
                                            child: Transform.scale(
                                              scale: _scaleSignup,
                                              child:
                                                  _animatedButtonUI("Continue"),
                                            ),
                                          ),
                                  ),
                                  Spacer(),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ]),
              );
            });
  }

  @override
  void initState() {
    _buttonControllerSignin = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    _buttonControllerSignup = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    backgroundAnimation =
        CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn);
    bubbleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    bubbleAnimation = CurvedAnimation(
        parent: bubbleController, curve: Curves.easeIn)
      ..addListener(() {})
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            addBubbles(animation: bubbleAnimation, topPos: -1.001, bubbles: 2);
            bubbleController.reverse();
          });
        }
        if (status == AnimationStatus.dismissed) {
          setState(() {
            addBubbles(animation: bubbleAnimation, topPos: -1.001, bubbles: 2);
            bubbleController.forward();
          });
        }
      });
    bubbleController.forward();

    setState(() {
      _isloading = true;
    });
    _getusername();
    super.initState();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _buttonControllerSignin.dispose();
    _buttonControllerSignup.dispose();
    bubbleController.dispose();
    super.dispose();
  }

  void _getusername() async {
    _username = await _sf.getUsername();
    print(_username);
    if (_username != null) {
      setState(() {
        _routeLayout = true;
      });
    } else {
      setState(() {
        _routeLayout = false;
      });
    }
    setState(() {
      _isloading = false;
    });
  }

  void addBubbles({animation, topPos = 0, leftPos = 0, bubbles = 15}) {
    for (var i = 0; i < bubbles; i++) {
      var range = Random(); // To use random import math.dart
      var minSize = range.nextInt(30).toDouble();
      var maxSize = range.nextInt(30).toDouble();
      var left = leftPos == 0
          ? range.nextInt(MediaQuery.of(context).size.width.toInt()).toDouble()
          : leftPos;
      var top = topPos == 0
          ? range.nextInt(MediaQuery.of(context).size.height.toInt()).toDouble()
          : topPos;

      var bubble = new Positioned(
          left: left,
          top: top,
          child: AnimatedBubble(
              animation: animation, startSize: minSize, endSize: maxSize));

      setState(() {
        areBubblesAdded = true;
        bubbleWidgets.add(bubble);
      });
    }
  }

  Widget _animatedButtonUI(String text) => Container(
        height: 70,
        width: MediaQuery.of(context).size.width - 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            boxShadow: [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 30.0,
                offset: Offset(0.0, 5.0),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0000FF),
                Color(0xFFFF3500),
              ],
            )),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      );

  void _onTapDownSignin(TapDownDetails details) {
    _buttonControllerSignin.forward();
  }

  void _onTapDownSignup(TapDownDetails details) {
    _buttonControllerSignup.forward();
  }

  void _onTapUpSignin(TapUpDetails details) {
    _buttonControllerSignin.reverse();
    Navigator.of(context).pushNamed(SIGN_IN);
  }

  void _onTapUpSignup(TapUpDetails details) {
    _buttonControllerSignup.reverse();
    if (_routeLayout) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                Home(username: _username, isDark: widget.isDark)),
      );
    } else {
      Navigator.of(context).pushNamed(SIGN_UP);
    }
  }
}
