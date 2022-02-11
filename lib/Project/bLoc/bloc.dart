
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:audio/MusicPlayer/View/ui.dart';
import 'package:audio/Project/View/ui.dart';
import 'package:audio/Project/bLoc/tempData.dart';
import 'package:audio/ProjectCreate/View/ui.dart';
import 'package:audio/WidgetElements/widgetElements.dart';
import 'package:audio/utils/appConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'Streams.dart';
import 'events.dart';
class ProjectScreenBloc{
  ProjectScreenBloc();
  bool isRecording = false;
  String  currentrecordingFilePath = "";
  Record record = Record();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance ;
  startListen(){
    ProjectScreenEventStream().projectScreenStream.outData.listen((event) async {
      if( event == projectScreenEvents.addLoopShowBottomSheet){
        // navigatorKey.currentContext!,
        showModalBottomSheet(isScrollControlled: true,
            context: navigatorKey.currentContext!,
            builder: (context) {
              return Container(color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15,left: 10,right: 10,bottom: 10),
                  child: Wrap(
                    //mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Loops",style: TextStyle(fontSize: 18),),
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: firestore.collection("loops").snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if(snapshot.hasData){
                              return ListView.builder(shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return InkWell(onTap: () async {
                                      ProjectScreenEventStream().projectScreenStream.dataReload(projectScreenEvents.loopSelected);

                                      audioLink = snapshot.data!.docs[index].get("file");
                                      audioWave = snapshot.data!.docs[index].get("wave");
                                      //loopSelected

                                      // var url = Uri.parse(snapshot.data!.docs[index].get("wave"));
                                      // var response = await http.get(url);
                                      // Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
                                      // String appDocumentsPath = appDocumentsDirectory.path; // 2
                                      // String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName").toString().replaceAll("mp3", "wave");
                                      // File fileWave = File(filePath);
                                      // await fileWave.writeAsBytes(response.bodyBytes);


                                    },
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                WidgetElements().AudioPlayer001(link: snapshot.data!.docs[index].get("file")),
                                                Text(snapshot.data!.docs[index].get("fileName"))
                                              ],
                                            ),
                                          ),
                                          Container(height: 0.4,color: Colors.white,width: width,),
                                        ],
                                      ),
                                    );

                                  });
                            }else{
                              return Center(child: Text("No Loops"),);
                            }
                          }),
                    ],
                  ),
                ),
              );

            });
      }
      if( event == projectScreenEvents.loopSelected){
        firestore.collection("projects").doc(currentProjectId).collection("tracks").add({"time":DateTime.now().millisecondsSinceEpoch,"file":audioLink,"wave":audioWave,"email":firebaseAuth.currentUser!.email,"fileName":audioLink.split('/').last,"uid":firebaseAuth.currentUser!.uid}).then((value) {
          Navigator.pop( navigatorKey.currentContext!);
          ProjectScreenEventStream().trackReloadStream.dataReload(true);
        });


      }
      if( event == projectScreenEvents.trackSelected){
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) =>  MusicPlayerScreen().Screen( wave:audioWave,link: audioLink,width: MediaQuery.of(context).size.width),
        ));

      }
      if( event == projectScreenEvents.recordingButtonPressed){
        final directory = await getApplicationDocumentsDirectory();
        if(isRecording == false){

          bool result = await record.hasPermission();
          if(result) {
            ProjectScreenEventStream().projectScreenStream.dataReload(projectScreenEvents.recordingStart);

            String path =directory.path;

              isRecording = !isRecording;

            currentrecordingFilePath =  path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";

            await record.start(
              path:currentrecordingFilePath, // required
              encoder: AudioEncoder.AMR_NB, // by default
              bitRate: 128000, // by default
            );
          }
        }else{

          if(isRecording == true){
            ProjectScreenEventStream().projectScreenStream.dataReload(projectScreenEvents.recordingEnds);
            record.stop().then((value) {
              record.dispose().then((value) {
                record = Record();
              });





              isRecording = !isRecording;
              Future.delayed(Duration(seconds: 1)).then((value) async {

                String path =directory.path;
                String  waveFile = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+'waveform.wave';
                print(waveFile);



                Stream<WaveformProgress> progressStream = JustWaveform.extract(
                  audioInFile: File(currentrecordingFilePath),
                  waveOutFile: File(waveFile),
                  zoom: const WaveformZoom.pixelsPerSecond(100),
                );

                progressStream.listen((waveformProgress) {

                  print('Progress: %${(100 * waveformProgress.progress).toInt()}');
                  if (waveformProgress.waveform != null) {

                    //  Waveform? waveform  = waveformProgress.waveform;
                    // Use the waveform.
                    print("use waveform");

                    firebase_storage.Reference refWave = storage.ref(firebaseAuth.currentUser!.uid+"/"+waveFile.split('/').last);
                    //firebase_storage.Reference ref = storage.ref(fileName);

                    refWave.putFile(File(waveFile)).then((valW) {
                      //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                      refWave.getDownloadURL().then((valueWaveFile) {
                        // String link = await ref.getDownloadURL();
                        print("wave uploaded");


                        firebase_storage.Reference ref = storage.ref(firebaseAuth.currentUser!.uid+"/"+currentrecordingFilePath.split('/').last);
                        //firebase_storage.Reference ref = storage.ref(fileName);

                        ref.putFile(File(currentrecordingFilePath)).then((val) {
                          //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                          ref.getDownloadURL().then((value) {
                            // String link = await ref.getDownloadURL();
                            print("audio uploaded");
                            // print(link);

                            firestore
                                .collection("projects")
                                .doc(currentProjectId).collection("tracks").add({"time":DateTime.now().millisecondsSinceEpoch,"file":value,"wave":valueWaveFile,"email":firebaseAuth.currentUser!.email,"fileName":currentrecordingFilePath.split('/').last,"uid":firebaseAuth.currentUser!.uid}).then((value) {
                              ProjectScreenEventStream().trackReloadStream.dataReload(true);
                            });
                          });


                        });





                      });


                    });



                  }
                });








              });
            });



          }

        }
      }
    });
  }



}