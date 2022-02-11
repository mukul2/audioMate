import 'package:firebase_auth/firebase_auth.dart';

import 'Streams.dart';
import 'events.dart';
class LoginScreenBloc{
  LoginScreenBloc();

  bool passwordValidated = false;
  bool emailValidated = false;

  bool loginButtonEnabled =  true;

  String email = "";
  String password = "";
  startBloc(){
    LoginScreenEventsStream.getInstance().outData.listen((event) async {
      if(event == loginEvents.loginButtonPressed){
        if(loginButtonEnabled){
          loginButtonEnabled =  false;
          LoginScreenEventsStream.getInstance().broadCast(loginEvents.loginButtonBusy);
          try{
            await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          }catch(e){
            loginButtonEnabled =  true;
            LoginScreenEventsStream.getInstance().broadCast(loginEvents.loginFailed);
            LoginScreenEventsStream.getInstance().broadCast(loginEvents.loginButtonFree);
          }

        }
      }
    });


    EmailFieldStream.getInstance().outData.listen((event) {
      if(event!=null){
        email = event;
        String pattern =
              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
              r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
              r"{0,253}[a-zA-Z0-9])?)*$";
          RegExp regex = new RegExp(pattern);
          if (!regex.hasMatch(event) || event == null) {
            emailValidated = false;
            LoginScreenEventsStream.getInstance().broadCast(
                loginEvents.emailFieldInvalidated);
          }
          else {
            emailValidated = true;
            LoginScreenEventsStream.getInstance().broadCast(
                loginEvents.emailFieldvalidated);
          }


      }

    });
    PasswordFieldStream.getInstance().outData.listen((event) {
      if(event!=null){
        password = event;
          if (event.length>5) {
            passwordValidated = true;
            LoginScreenEventsStream.getInstance().broadCast(
                loginEvents.passwordFieldValidated);
          }
          else{
        passwordValidated = false;
        LoginScreenEventsStream.getInstance().broadCast(loginEvents.passwordFieldInValidated);
      }



      }

    });
  }
}