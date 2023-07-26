import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //create instance of firebase auth
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //register

  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        await DataBaseServices(uid: user.user!.uid)
            .savingUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);

      return e.message;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //Logout User
  Future logUserOut() async {
    try {
      HelperFunctions.saveUserLoggenInStatus(false);
      HelperFunctions.saveUserEmailKey("");
      HelperFunctions.saveUserNameKey("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
