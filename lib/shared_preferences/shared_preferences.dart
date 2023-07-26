import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions{

  //keys
  static String userLoggedInKey = "USERLOGGEDINKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userNameKey = "USERNAMEKEY";




  //saving data to SF
  static Future saveUserLoggenInStatus(bool status) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setBool(userLoggedInKey, status);
  }


  static Future saveUserEmailKey (String email) async {
     SharedPreferences sf = await SharedPreferences.getInstance();
     sf.setString(userEmailKey, email);
  }

  static Future saveUserNameKey(String fullName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setString(userNameKey, fullName);
  }

  //getting data from SF

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

}