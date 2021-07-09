import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:locationtracker/pages/groups/groups.dart';
import 'package:locationtracker/pages/groups/search.dart';
import 'package:locationtracker/pages/authentication/signin.dart';
import 'package:locationtracker/pages/authentication/signup.dart';
import 'package:locationtracker/pages/welcomescreen/welcomescreen.dart';
import 'package:locationtracker/helpers/sharedpref.dart';
import 'constants/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        initialRoute: WELCOME_SCREEN,
        routes: {
          WELCOME_SCREEN: (context) => WelcomeScreen(),
          SIGN_IN: (context) => Signinpage(title: "sign in"),
          SIGN_UP: (context) => Signuppage(title: "sign up"),
          SEARCH:(context)=>Search()
        });
  }
}



