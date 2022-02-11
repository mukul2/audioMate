import 'package:audio/Project/View/ui.dart';
import 'package:audio/Project/bLoc/tempData.dart';
import 'package:audio/ProjectCreate/View/ui.dart';
import 'package:audio/WidgetElements/widgetElements.dart';
import 'package:audio/utils/appConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Streams.dart';
import 'events.dart';
class MusicPlayerScreenBloc{
  MusicPlayerScreenBloc();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance ;
  startListen(){
    // ProjectScreenEventStream().projectScreenStream.outData.listen((event) {
    //
    // });
  }



}