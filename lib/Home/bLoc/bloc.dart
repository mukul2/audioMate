import 'package:audio/Auth/Service/AuthRepository.dart';
import 'package:audio/Project/View/ui.dart';
import 'package:audio/ProjectCreate/View/ui.dart';
import 'package:audio/UploadAudio/View/ui.dart';
import 'package:audio/utils/appConst.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Streams.dart';
import 'events.dart';
class HomeScreenBloc{
  HomeScreenBloc();
  startListen(){
    print("instance");

    HomeScreenEventStream().homeScreenProjectClickedStream.outData.listen((event) {
      print("project clicked");
      print(event.data().toString());
      Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => ProjectScreen().Screen(data: event)),);

      //ProjectScreen
    });

    HomeScreenEventStream().homeScreenEventsStream.outData.listen((event) {
      if(event == homeScreenEvents.createProject){
        Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => CreateProjectUI().Screen()),);
      }

      if(event == homeScreenEvents.uploadAudio){
        Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => UploadAudioUI().Screen()),);
      }


      if(event == homeScreenEvents.logoutClicked){
        AppAuth().logout();
      }


    });
  }



}