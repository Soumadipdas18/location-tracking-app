import 'package:flutter/material.dart';
import 'package:locationtracker/models/custom_shape.dart';
import 'package:locationtracker/models/responsive_ui.dart';

class Help extends StatelessWidget {
  Help({Key? key, required this.isDark}) : super(key: key);
  final bool isDark;
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
      appBar: PreferredSize(
          child: clipShape(context),
          preferredSize: Size(_width!, _height! / 3)),
      body: Card(
        color:!isDark? Colors.grey[300]:Colors.grey[900],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'This App can only track location when user is present in the maps screen',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: _large ? 20 : (_medium ? 17.5 : 15),
                  ),
                )),
            Spacer(),
          ],
        ),
      ),
    );
  }
  Widget clipShape(BuildContext context) {
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
                    !isDark ? ThemeData().accentColor : Color(0xff6d6666),
                    !isDark ? ThemeData().primaryColor : Color(0xff000000)
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
                    !isDark ? ThemeData().accentColor : Color(0xff868181),
                    !isDark ? ThemeData().primaryColor : Color(0xff474646)
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
                'HELP',
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
