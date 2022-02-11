import 'package:audio/Auth/bLoc/Streams.dart';
import 'package:audio/Auth/bLoc/events.dart';
import 'package:audio/WidgetElements/widgetElements.dart';
import 'package:audio/utils/appConst.dart';
import 'package:audio/utils/textConst.dart';
import 'package:audio/utils/textStyleConst.dart';
import 'package:audio/utils/themeManager.dart';
import 'package:flutter/material.dart';

class LoginUI{

  LoginUI();
  Screen(){
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(body: Center(
      child: Container(margin: EdgeInsets.all(width*0.04),child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          StreamBuilder<loginEvents>(
              stream: LoginScreenEventsStream.getInstance().outData,
              builder: (c, snapshot) {
                return Container(
                  margin: EdgeInsets.only(bottom: height * 0.002),
                  child: TextFormField(onChanged: (val)=>EmailFieldStream.getInstance().broadCast(val),
                    autovalidateMode: AutovalidateMode.always,
                    //autovalidateMode: AutovalidateMode.onUserInteraction,
                    //  validator: validateEmail,
                    obscureText: false,
                    controller:
                    emailController,
                    keyboardType: TextInputType
                        .emailAddress,
                    style: interMedium.copyWith(
                        fontSize:
                        width * 0.045),
                    cursorColor: ThemeManager()
                        .getDarkGreenColor,
                    decoration:
                    new InputDecoration(
                      fillColor: ThemeManager()
                          .getLightGreenTextFieldColor,
                      filled: true,
                      border: InputBorder.none,
                      hintText: "Email Address",
                      hintStyle: interMedium.copyWith(
                          color: ThemeManager()
                              .getLightGrey1Color,
                          fontSize:
                          width * 0.034),
                    ),


                    validator: (val) =>snapshot.hasData && snapshot.data == loginEvents.emailFieldInvalidated?"Use propper email":"",
                  ),
                );
              }),
          StreamBuilder<loginEvents>(
              stream: LoginScreenEventsStream.getInstance().outData,
              builder: (c, snapshot) {
                return TextFormField(
                  onChanged: (val)=>PasswordFieldStream.getInstance().broadCast(val),
                  validator: (val) =>snapshot.hasData && snapshot.data == loginEvents.passwordFieldInValidated?"Password is minimum 6 chracter/digit":"",

                  obscureText: true,
                  controller:
                  passwordController,
                  autovalidateMode:
                  AutovalidateMode
                      .onUserInteraction,
                  keyboardType: TextInputType
                      .visiblePassword,
                  style: interMedium.copyWith(
                      fontSize: width * 0.045),
                  cursorColor: ThemeManager()
                      .getDarkGreenColor,
                  decoration:
                  new InputDecoration(
                    border: InputBorder.none,
                    fillColor: ThemeManager()
                        .getLightGreenTextFieldColor,
                    filled: true,
                    hintText: "Password",
                    hintStyle: interMedium.copyWith(
                        color: ThemeManager()
                            .getLightGrey1Color,
                        fontSize:
                        width * 0.034),
                  ),
                );
              }),



          GestureDetector(onTap: (){
            LoginScreenEventsStream.getInstance().broadCast(loginEvents.loginButtonPressed);
          },child: StreamBuilder<loginEvents>(
              stream: LoginScreenEventsStream.getInstance().outData,
              builder: (c, snapshot) {
                if(snapshot.hasData && snapshot.data == loginEvents.loginButtonBusy){
                  return Container(
                      margin: EdgeInsets.only(
                         // left: width * 0.05,
                         // right: width * 0.05,
                          bottom: height * 0.05,
                          top: height * 0.05),
                      child: WidgetElements().bigButton(label: "Please wait") );
                }
                return Container(
                    margin: EdgeInsets.only(
                      //  left: width * 0.05,
                      //  right: width * 0.05,
                        bottom: height * 0.05,
                        top: height * 0.05),
                    child: WidgetElements().bigButton(label: "Login"));

              }),),



        ],
      ),),
    ),);
  }
}