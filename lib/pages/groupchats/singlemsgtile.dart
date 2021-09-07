import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final int milisec;
  final String username;
  final Color backcolor;
  final bool isDark;

  MessageTile(
      {required this.message,
      required this.username,
      required this.sendByMe,
      required this.milisec,
      required this.backcolor,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 2, bottom: 2, left: sendByMe ? 0 : 12, right: sendByMe ? 12 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: sendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10))
              : BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
          color: backcolor,
        ),
        child: Column(
            crossAxisAlignment:
                sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                username,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : (sendByMe ? Colors.white : Colors.black),
                    fontSize: 14,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                message,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : (sendByMe ? Colors.white : Colors.black),
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 7.0,
              ),
              Text(timeConvert(milisec),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : (sendByMe ? Color(0xFFD4D3D3) : Colors.black),
                      fontSize: 10,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300))
            ]),
      ),
    );
  }

  String timeConvert(int timeInMillis) {
    var time = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    var formattedtime = DateFormat('hh:mm a').format(time);
    return formattedtime;
  }
}
