import 'dart:io';

import 'package:audio/Home/bLoc/Streams.dart';
import 'package:audio/ProjectCreate/bLoc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;


import 'package:audio/Home/bLoc/events.dart';
import 'package:audio/Home/bLoc/Streams.dart';
import 'package:audio/Home/bLoc/bloc.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';
class CreateProjectUI{
  CreateProjectUI();
  Screen(){
    ProjectCreateScreenBloc().startListen();
    return CreateNewProject();
  }


}
Future<String>  localPath() async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}




class CreateNewProject extends StatefulWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  CreateNewProject({Key? key}) : super(key: key);

  @override
  _CreateNewProjectState createState() => _CreateNewProjectState();
}

class _CreateNewProjectState extends State<CreateNewProject> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(child: SafeArea(child: Scaffold(appBar: AppBar(title: Text("Create Project"),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(margin: EdgeInsets.only(top: 20),
              child: TextFormField(controller: controller,decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.white, fontSize: 16.0),filled: true,fillColor: Colors.white
              ),

              ),
            ),
            InkWell(onTap: (){
              if(controller.text.length>0){
                widget.firestore.collection("projects").add({"time":DateTime.now().millisecondsSinceEpoch,"title":controller.text,"uid":widget.auth.currentUser!.uid});
                Navigator.pop(context);
              }

            },
              child: Container(margin: EdgeInsets.only(top: 15,bottom: 15),height: 55,decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5)
              ),child: Center(child:Text("Create",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17),),),),
            ),

          ],
        ),
      ),
    ),),);
  }
}




