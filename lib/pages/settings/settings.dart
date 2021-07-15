import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:locationtracker/helpers/sharedpref.dart';
import 'package:settings_ui/settings_ui.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({Key? key, required this.username, required this.useruid})
      : super(key: key);
  final String username;
  final String useruid;
  @override
  _SettingspageState createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  late bool isSwitcheddark;
  bool isloading = true;
  sharedpref _sf = new sharedpref();
  int count = 0;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to save changes'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  if (count > 0) {
                    print(isSwitcheddark);
                    await _sf.saveIsDakEnabled(isSwitcheddark);
                    Phoenix.rebirth(context);
                  } else
                    Navigator.of(context).pop(true);
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: !isSwitcheddark ? Colors.white : Color(0xff000000),
        appBar: AppBar(
            title: Text("Settings"),
            centerTitle: true,
            // backgroundColor:
            //     !isSwitcheddark ? ThemeData().accentColor : Color(0xff6d6666)),
        ),
        body: isloading
            ? Center(child: CircularProgressIndicator())
            : SettingsList(
                sections: [
                  SettingsSection(
                    titlePadding: EdgeInsets.all(20),
                    title: 'Display',
                    tiles: [
                      SettingsTile.switchTile(
                        title: 'Enable Dark Mode',
                        leading: Icon(Icons.phone_android),
                        switchValue: isSwitcheddark,
                        onToggle: (value) {
                          setState(() {
                            isSwitcheddark = value;
                          });
                          count++;
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getsharedpref().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> getsharedpref() async {
    isSwitcheddark = await _sf.getIsDakEnabled();
    setState(() {
      isloading = false;
    });
  }
}
