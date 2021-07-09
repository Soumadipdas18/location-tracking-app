import 'package:shared_preferences/shared_preferences.dart';

class sharedpref {
  saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username',username);
  }
  getUsername() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.getString('username');
    }
    catch(e){
      return null;
    }
  }

}