import 'package:flutter/material.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({Key? key,required this.username, required this.isDark}) : super(key: key);
  final String username;
  final bool isDark;

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text("FUCK"),);
  }
}
