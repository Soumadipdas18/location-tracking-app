import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:locationtracker/helpers/sharedpref.dart';
import 'package:locationtracker/pages/authentication/signin.dart';
import 'package:locationtracker/pages/authentication/signup.dart';
import 'package:locationtracker/pages/welcomescreen/welcomescreen.dart';
import 'constants/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  configLoading();
  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}
void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..userInteractions = false
    ..dismissOnTap = false;
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkEnabled;
  bool isloading = true;

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Center(child: CircularProgressIndicator())
        : MaterialApp(
            title: 'Location Tracker',
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Colors.blueAccent,
              accentColor: Colors.blue[200],
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              /* dark theme settings */
            ),
            themeMode: isDarkEnabled ? ThemeMode.dark : ThemeMode.light,
            initialRoute: WELCOME_SCREEN,
            routes: {
                WELCOME_SCREEN: (context) => WelcomeScreen(
                      isDark: isDarkEnabled,
                    ),
                SIGN_IN: (context) => Signinpage(
                      title: "sign in",
                      isDark: isDarkEnabled,
                    ),
                SIGN_UP: (context) => Signuppage(
                      title: "sign up",
                      isDark: isDarkEnabled,
                    ),
              },builder: EasyLoading.init(),);

  }

  @override
  void initState() {
    super.initState();
    getshared();
  }

  getshared() async {
    sharedpref _sf = new sharedpref();
    isDarkEnabled = await _sf.getIsDakEnabled();
    setState(() {
      isloading = false;
    });
  }
}
