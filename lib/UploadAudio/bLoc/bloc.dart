import 'dart:io';

import 'package:audio/ProjectCreate/View/ui.dart';
import 'package:audio/utils/appConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'Streams.dart';
import 'events.dart';
class UploadAudioScreenBloc{
  UploadAudioScreenBloc();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  startListen(){
    UploadAudioScreenEvents().stream.outData.listen((event) async {
      if( event == uploadAudioScreenEvents.uploadAudioGuiter  || event == uploadAudioScreenEvents.uploadAudioOthers ){

        UploadAudioScreenEvents().stream.broadCast(uploadAudioScreenEvents.uploadAudioBusy);

        print("upload guiter");
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

              firebase_storage.Reference refWave = storage.ref(auth.currentUser!.uid + "/" + waveFile
                      .split('/')
                      .last);
              //firebase_storage.Reference ref = storage.ref(fileName);

              refWave.putFile(File(waveFile)).then((valW) {
                //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                refWave.getDownloadURL().then((valueWaveFile) {
                  // String link = await ref.getDownloadURL();
                  print("wave uploaded");




                  firebase_storage.Reference ref = storage.ref(auth.currentUser!.uid+"/"+file.path.split('/').last);
                  //firebase_storage.Reference ref = storage.ref(fileName);

                  ref.putFile(File(file.path)).then((val) {
                    //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                    ref.getDownloadURL().then((value) {
                      // String link = await ref.getDownloadURL();
                      print("audio uploaded");
                      // print(link);

                      firestore
                          .collection("loops").add({"type":event == uploadAudioScreenEvents.uploadAudioGuiter? "guiter":"others","time":DateTime.now().millisecondsSinceEpoch,"file":value,"wave":valueWaveFile,"email":auth.currentUser!.email,"fileName":file.path.split('/').last,"uid":auth.currentUser!.uid});
                      print("loop added");
                      UploadAudioScreenEvents().stream.broadCast(uploadAudioScreenEvents.uploadAudioFree);
                    });


                  });





                });
              });
            };






          });


        } else {
          // User canceled the picker
        }

      }
    });
  }



}