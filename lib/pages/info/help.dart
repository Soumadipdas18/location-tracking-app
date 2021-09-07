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
}
