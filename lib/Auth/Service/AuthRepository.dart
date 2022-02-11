import 'dart:convert';
import 'dart:io';

import 'package:audio/Auth/bLoc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'AuthStatus.dart';
import 'Streams.dart';
dynamic? userDataSecondary;
class AppAuth{
  AppAuth? appAuth;
  AppAuth? getInstance(){
   if( appAuth==null){
     appAuth = AppAuth();
   }
   return appAuth;

  }
  User? user;

  FirebaseAuth auth =  FirebaseAuth.instance;

  logout(){
    auth.signOut();
  }
  Stream<AuthState> checkAuth (){
    LoginScreenBloc().startBloc();
    auth.authStateChanges().listen((event) async {
      if(event!=null && event!.uid!=null){
        user = event;

        UserAuthStream.getInstance().broadCast(AuthState.authenticatedUser);
      }else{
        user = null;
        UserAuthStream.getInstance().broadCast(AuthState.unauthenticated);
      }



    });

    return UserAuthStream.getInstance().outData;
  }


}



