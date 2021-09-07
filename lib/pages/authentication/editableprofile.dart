import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  final bool isDark;

  const EditProfilePage(
      {Key? key, required this.username, required this.isDark})
      : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final String uid;
  late final User user;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            const Divider(
              height: 1.0,
            ),
            new ListTile(
              leading: Icon(Icons.label),
              title: const Text('Username'),
              subtitle: Text(widget.username),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Email Address'),
              subtitle: Text(user.email!),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    user = auth.currentUser!;
    uid = user.uid;
  }
}
