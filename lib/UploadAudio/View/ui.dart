import 'dart:io';

import 'package:audio/Home/bLoc/Streams.dart';
import 'package:audio/ProjectCreate/bLoc/bloc.dart';
import 'package:audio/UploadAudio/bLoc/Streams.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:audio/UploadAudio/bLoc/events.dart';

import 'package:audio/Home/bLoc/events.dart';
import 'package:audio/Home/bLoc/Streams.dart';
import 'package:audio/Home/bLoc/bloc.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';
class UploadAudioUI{
  UploadAudioUI();
  Screen(){
    ProjectCreateScreenBloc().startListen();
    return SoundUpload();
  }


}
Future<String>  localPath() async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}
class SoundUpload extends StatefulWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  SoundUpload();

  @override
  _SoundUploadState createState() => _SoundUploadState();
}

class _SoundUploadState extends State<SoundUpload> {
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {

    //uploadAudioBusy

    return  StreamBuilder<uploadAudioScreenEvents>(
        stream: UploadAudioScreenEvents().stream.outData,
        builder: (c, snapshot) {

          if(snapshot.hasData && snapshot.data ==uploadAudioScreenEvents.uploadAudioBusy){
            return Container(child: SafeArea(
              child: Scaffold(appBar: AppBar(title: Text("Please wait"),),
                body: Center(child: CircularProgressIndicator(),),
              ),
            ),);



          }else{
            return Container(child: SafeArea(
              child: Scaffold(appBar: AppBar(title: Text("Upload track"),),
                body: Column(
                  children: [
                    InkWell(onTap: () async {
                      UploadAudioScreenEvents().stream.broadCast(uploadAudioScreenEvents.uploadAudioGuiter);

                    },
                      child: Container(margin: EdgeInsets.all(8.0),decoration: BoxDecoration(color: Colors.deepPurpleAccent),child: Center(child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("Guiter",style: TextStyle(color: Colors.white),),
                      ),),),
                    ),
                    InkWell(onTap: () async {
                      UploadAudioScreenEvents().stream.broadCast(uploadAudioScreenEvents.uploadAudioOthers);

                    },
                      child: Container(margin: EdgeInsets.all(8.0),decoration: BoxDecoration(color: Colors.redAccent),child: Center(child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("Others",style: TextStyle(color: Colors.white),),
                      ),),),
                    ),

                  ],
                ),
              ),
            ),);
          }


        });

    return Container(child: SafeArea(
      child: Scaffold(appBar: AppBar(title: Text("Upload track"),),
        body: Column(
          children: [
            InkWell(onTap: () async {
              UploadAudioScreenEvents().stream.broadCast(uploadAudioScreenEvents.uploadAudioGuiter);

            },
              child: Container(margin: EdgeInsets.all(8.0),decoration: BoxDecoration(color: Colors.deepPurpleAccent),child: Center(child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Guiter",style: TextStyle(color: Colors.white),),
              ),),),
            ),
            InkWell(onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,allowMultiple: false
                allowedExtensions: ['mp3', 'wav', ],
              );
              if (result != null) {
                File file = File(result.files.single.path!);

                String path =await localPath();
                String  waveFile = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+'waveform.wave';
                print(waveFile);



                Stream<WaveformProgress> progressStream = JustWaveform.extract(
                  audioInFile: File(file.path),
                  waveOutFile: File(waveFile),
                  zoom: const WaveformZoom.pixelsPerSecond(100),
                );

                progressStream.listen((waveformProgress) {

                  print('Progress: %${(100 * waveformProgress.progress).toInt()}');
                  if (waveformProgress.waveform != null) {
                    //  Waveform? waveform  = waveformProgress.waveform;
                    // Use the waveform.
                    print("use waveform");

                    firebase_storage.Reference refWave = storage.ref(
                        widget.auth.currentUser!.uid + "/" + waveFile
                            .split('/')
                            .last);
                    //firebase_storage.Reference ref = storage.ref(fileName);

                    refWave.putFile(File(waveFile)).then((valW) {
                      //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                      refWave.getDownloadURL().then((valueWaveFile) {
                        // String link = await ref.getDownloadURL();
                        print("wave uploaded");




                        firebase_storage.Reference ref = storage.ref(widget.auth.currentUser!.uid+"/"+file.path.split('/').last);
                        //firebase_storage.Reference ref = storage.ref(fileName);

                        ref.putFile(File(file.path)).then((val) {
                          //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                          ref.getDownloadURL().then((value) {
                            // String link = await ref.getDownloadURL();
                            print("audio uploaded");
                            // print(link);

                            widget.firestore
                                .collection("loops").add({"type":"others","time":DateTime.now().millisecondsSinceEpoch,"file":value,"wave":valueWaveFile,"email":widget.auth.currentUser!.email,"fileName":file.path.split('/').last,"uid":widget.auth.currentUser!.uid});
                            print("loop added");
                          });


                        });





                      });
                    });
                  };






                });


              } else {
                // User canceled the picker
              }




            },
              child: Container(margin: EdgeInsets.all(8.0),decoration: BoxDecoration(color: Colors.redAccent),child: Center(child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Others",style: TextStyle(color: Colors.white),),
              ),),),
            ),
          ],
        ),
      ),
    ),);
  }
}