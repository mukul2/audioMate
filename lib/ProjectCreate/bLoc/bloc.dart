import 'package:audio/ProjectCreate/View/ui.dart';
import 'package:audio/utils/appConst.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Streams.dart';
import 'events.dart';
class ProjectCreateScreenBloc{
  ProjectCreateScreenBloc();
  startListen(){
    HomeScreenEventStream().homeScreenEventsStream.outData.listen((event) {
      if(false &&  event == homeScreenEvents.createProject){
        Navigator.push(
            navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => CreateProjectUI().Screen()),
        );
      }
    });
  }



}