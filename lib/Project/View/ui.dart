import 'dart:io';
import 'dart:math';

import 'package:audio/Home/bLoc/Streams.dart';
import 'package:audio/Project/bLoc/Streams.dart';
import 'package:audio/Project/bLoc/tempData.dart';
import 'package:audio/ProjectCreate/bLoc/bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

import 'package:audio/Project/bLoc/events.dart';
import 'package:audio/Home/bLoc/events.dart';
import 'package:audio/Home/bLoc/Streams.dart';
import 'package:audio/Home/bLoc/bloc.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
class ProjectScreen{
      ProjectScreen();
      Screen({required QueryDocumentSnapshot data}){
    //ProjectCreateScreenBloc().startListen();
    return Project(queryDocumentSnapshot: data,);
  }




}





Future<String>  localPath() async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}



class Project extends StatefulWidget {
  QueryDocumentSnapshot queryDocumentSnapshot ;
  Project({required this.queryDocumentSnapshot});
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String currentrecordingFilePath = "";
  bool isProcessing = false;


  @override
  _ProjectState createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  bool recording = false;
  bool showGrid = false;
  List<AudioPlayer>allAudioOnly = [];
  List<int>allDelay = [];
  int maxMusicIndex = 0 ;
  int maxMusicIndexHelper = 0 ;
  @override
  Widget build(BuildContext context) {
    double width =  MediaQuery.of(context).size.width;

    return SafeArea(child:Scaffold(appBar: AppBar(actions: [

      IconButton(onPressed: (){
        widget.queryDocumentSnapshot.reference.delete();
        Navigator.pop(context);
      }, icon: Icon(Icons.delete))
    ],title: Text(widget.queryDocumentSnapshot.get("title")),),body: Stack(
      children: [
        Positioned(bottom: 0,right: 0,left: 0,child: Container(height: 60,child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,children: [

          Card(elevation: 5,color: showGrid? Colors.redAccent:Colors.grey,shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27.5),
          ),
            child: Container(height: 55,width: 55,
              child: Center(
                child: IconButton(onPressed: (){
                  setState(() {
                    showGrid = !showGrid;
                  });




                },icon: Icon(Icons.grid_on,color: Colors.white, ),),
              ),
            ),
          ),


          Card(elevation: 5,color: Colors.redAccent,shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27.5),
          ),
            //allAudioOnly[maxMusicIndex].
            child: Container(height: 55,width: 55,
              child: Center(
                child: IconButton(onPressed: (){
                  print("delays");
                  if(allAudioOnly.length>0){
                    print(allDelay);


                    //maxLenght

                    for(int i = 0 ; i < allAudioOnly.length ; i++){
                      Future.delayed(Duration(milliseconds: allDelay[i])).then((value) {
                        allAudioOnly[i].resume();
                      });


                    }
                  }



                },icon: Icon(Icons.play_arrow,color: Colors.white, ),),
              ),
            ),
          ),
          Card(elevation: 5,color: Colors.redAccent,shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27.5),
          ),
            child: Container(height: 55,width: 55,
              child: Center(
                child: IconButton(onPressed: (){

                  ProjectScreenEventStream().projectScreenStream.dataReload(projectScreenEvents.addLoopShowBottomSheet);


                },icon: Icon(Icons.music_note,color: Colors.white, ),),
              ),
            ),
          ),
          Card(elevation: 5,color: Colors.redAccent,shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27.5),
          ),
            child: Container(height: 55,width: 55,
              child: Center(
                //ProjectScreenEventStream
               // child: MicForProject(projectId: widget.queryDocumentSnapshot.id,),
               // child: MicForProject(projectId: widget.queryDocumentSnapshot.id,),
                child: IconButton(onPressed: (){

                  ProjectScreenEventStream().projectScreenStream.dataReload(projectScreenEvents.recordingButtonPressed);


                },icon:     StreamBuilder<projectScreenEvents>(
                    stream: ProjectScreenEventStream().projectScreenStream.outData,
                    builder: (BuildContext context, AsyncSnapshot<projectScreenEvents> snapshot) {
                      if(snapshot.hasData){
                        if(snapshot.data == projectScreenEvents.recordingStart){
                          return Icon(Icons.stop,color: Colors.white,);
                        }else{
                          return Icon(Icons.fiber_manual_record,color: Colors.white,);
                        }
                      }else{
                        return Icon(Icons.fiber_manual_record,color: Colors.white,);
                      }
                    }),),
              ),
            ),
          ),
        ],),)),
        // ProjectScreenEventStream().projectScreenStream

        Align(alignment: Alignment.center,child:  StreamBuilder<bool>(
            stream: ProjectScreenEventStream().trackReloadStream.outData,
            builder: (c, snapshotAuth) {
              return FutureBuilder<QuerySnapshot>(
                  future: widget.firestore.collection("projects").doc(widget.queryDocumentSnapshot.id).collection("tracks").orderBy("time",descending: true).get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(snapshot.hasData && snapshot.data!.docs.length>0){
                      allAudioOnly.clear();
                      int maxLenght = 0 ;
                      List<Widget> allAudio = [] ;
                      List<int>allDurations = [];
                      maxMusicIndex = 0 ;
                      maxMusicIndexHelper = 0 ;


                      Future<int>getMusicLenghtOnly({required String link}) async {
                        print("called "+link);
                        AudioPlayer advancedPlayer = AudioPlayer();
                        await advancedPlayer.setUrl(link);
                        allAudioOnly.add(advancedPlayer);

                        // await  advancedPlayer.setUrl(link);

                        Duration dd =  await advancedPlayer.onDurationChanged.first;

                        if(maxLenght<dd.inMilliseconds){
                          maxLenght = dd.inMilliseconds;
                          maxMusicIndex = maxMusicIndexHelper;
                        };
                        maxMusicIndexHelper++;
                        return dd.inMilliseconds;
                        return  await advancedPlayer.getDuration();
                        // return d.inMilliseconds;

                      }

                      Future cacheAllData() async {
                        for(int i = 0 ; i < snapshot.data!.docs.length ; i++){

                          try{
                            //delay
                            allDelay.add( snapshot.data!.docs[i].get("delay"));
                          }catch(e){

                          }
                          allDelay.add(0);

                          allDurations.add( await getMusicLenghtOnly(link: snapshot.data!.docs[i].get("file")));
                          if(i+1 == snapshot.data!.docs.length){
                            ProjectScreenEventStream().maxDurationFounndStream.dataReload(true);
                            // MaxDurationFounndStream.getInstance().dataReload(true);

                          }


                        }
                      }


                      return  FutureBuilder(
                          future: cacheAllData(), // async work
                          builder: (BuildContext context, AsyncSnapshot snapshotCache) {
                            if(snapshotCache.connectionState == ConnectionState.done){
                              for(int j = 0 ; j < snapshot.data!.docs.length ; j++){
                                Future<String> downloadFile({required String link})async{
                                  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

                                  String appDocumentsPath = appDocumentsDirectory.path; // 2
                                  String filePath = '$appDocumentsPath/'+snapshot.data!.docs[j].get("fileName").toString().replaceAll("mp3", "wave");

                                  if(await File(filePath).exists())return filePath;

                                  var url = Uri.parse(snapshot.data!.docs[j].get("wave"));
                                  var response = await http.get(url);

                                  File file = File(filePath);
                                  await file.writeAsBytes(response.bodyBytes);
                                  return filePath;

                                }

                                Future<int>getMusicLenght({required String link}) async {
                                  print("called "+link);
                                  AudioPlayer advancedPlayer = AudioPlayer();

                                  // await  advancedPlayer.setUrl(link);
                                  advancedPlayer.play(link);
                                  Duration dd =  await advancedPlayer.onDurationChanged.first;
                                  //  if(maxLenght<dd.inMilliseconds) maxLenght = dd.inMilliseconds;
                                  return dd.inMilliseconds;
                                  return  await advancedPlayer.getDuration();
                                  // return d.inMilliseconds;



                                }
                                allAudio.add( FutureBuilder<String>(
                                  future: downloadFile(link: snapshot.data!.docs[j].get("file")), // async work
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshotW) {
                                    switch (snapshotW.connectionState) {
                                      case ConnectionState.done:

                                        return InkWell(onTap: (){


                                          audioLink =  snapshot.data!.docs[j].get("file");
                                          audioWave = snapshotW.data!;

                                          ProjectScreenEventStream().projectScreenStream.dataReload(projectScreenEvents.trackSelected);

                                        },child:true?StreamBuilder(
                                            stream:MaxDurationFounndStream.getInstance().outData,
                                            builder: (BuildContext context, AsyncSnapshot<bool> snapshotDurationFound) {
                                              // return Text((MediaQuery.of(context).size.width*((allDurations[j])/maxLenght)).toString());
                                              //return  Container(width:  MediaQuery.of(context).size.width*((allDurations[j])/maxLenght), child: SingleAudioGraph(wi:  MediaQuery.of(context).size.width*((allDurations[j])/maxLenght),link: snapshotW.data!,));

                                              return Draggablletrack(onTrackPositionChanged: (val){
                                                print(val["offsetScale"]*maxLenght/1000);
                                                widget.firestore.collection("projects").doc(widget.queryDocumentSnapshot.id).collection("tracks").doc(snapshot.data!.docs[j].id).update({"delay":(val["offsetScale"]*maxLenght).toInt()});

                                                allDelay[j]=(val["offsetScale"]*maxLenght).toInt();
                                              },widget: Container(width:  MediaQuery.of(context).size.width*((allDurations[j])/maxLenght), child: SingleAudioGraph(wi:  MediaQuery.of(context).size.width*((allDurations[j])/maxLenght),link: snapshotW.data!,)),width:  MediaQuery.of(context).size.width*((allDurations[j])/maxLenght),starts:(MediaQuery.of(context).size.width)* (allDelay[j]/maxLenght).toDouble(),);


                                              return Container(height: 50,color: Colors.redAccent,width:  MediaQuery.of(context).size.width*0.5,);

                                              return Text((MediaQuery.of(context).size.width*allDurations[j]/maxLenght).toString()+" "+MediaQuery.of(context).size.width.toString());
                                              return  Container(width:  MediaQuery.of(context).size.width*((allDurations[j])/maxLenght), child: SingleAudioGraph(wi:  MediaQuery.of(context).size.width*((allDurations[j])/maxLenght),link: snapshotW.data!,));

                                              if(snapshotDurationFound.hasData){
                                                return Text((MediaQuery.of(context).size.width*((allDurations[j])/maxLenght)).toString());
                                                return   Container(width: MediaQuery.of(context).size.width*((allDurations[j])/maxLenght) , child: SingleAudioGraph(wi: 10,link: snapshotW.data!,));

                                              }else{
                                                return  Container(width:  MediaQuery.of(context).size.width, child: SingleAudioGraph(wi: 10,link: snapshotW.data!,));

                                              }
                                            }): FutureBuilder<int>(
                                          future: getMusicLenght(link: snapshot.data!.docs[j].get("file")), // async work
                                          builder: (BuildContext context, AsyncSnapshot<int> snapshotD) {
                                            if(snapshotD.hasData){
                                              return  StreamBuilder(
                                                  stream:MaxDurationFounndStream.getInstance().outData,
                                                  builder: (BuildContext context, AsyncSnapshot<bool> snapshotDurationFound) {
                                                    if(snapshotDurationFound.hasData){
                                                      return   Container(width: MediaQuery.of(context).size.width*((snapshotD.data!)/maxLenght) , child: SingleAudioGraph(wi: 10,link: snapshotW.data!,));

                                                    }else{
                                                      return  Container(width:  MediaQuery.of(context).size.width, child: SingleAudioGraph(wi: 10,link: snapshotW.data!,));

                                                    }
                                                  });
                                              Text(((snapshotD.data!)/maxLenght).toString());
                                              Container(width:  MediaQuery.of(context).size.width*((snapshotD.data!)/maxLenght) , child: SingleAudioGraph(wi: 10,link: snapshotW.data!,));
                                              return Row(
                                                children: [
                                                  // Text((snapshotD.data!).toString()),
                                                  StreamBuilder(
                                                      stream:MaxDurationFounndStream.getInstance().outData,
                                                      builder: (BuildContext context, AsyncSnapshot<bool> snapshotDurationFound) {
                                                        if(snapshotDurationFound.hasData){
                                                          return   Container(width: MediaQuery.of(context).size.width*((snapshotD.data!)/maxLenght) , child: SingleAudioGraph(wi: 10,link: snapshotW.data!,));

                                                        }else{
                                                          return  Container(width:  MediaQuery.of(context).size.width*((snapshotD.data!)/maxLenght) , child: SingleAudioGraph(wi: 10,link: snapshotW.data!,));

                                                        }
                                                      }),


                                                ],
                                              );
                                              return Text((snapshotD.data!).toString());
                                            }else{
                                              return Text("--");
                                            }
                                          },
                                        ));
                                      default:
                                        if (snapshot.hasError)
                                          return Text('Error: ${snapshot.error}');
                                        else
                                          return Container(height: 0,width: 0,);
                                        return Text('Result: ${snapshot.data}');
                                    }
                                  },
                                ));

                              }
                              List<Widget> times = [] ;
                              List<Widget> rows = [] ;
                              double height = MediaQuery.of(context).size.height;
                              for(int l = 0 ; l < (maxLenght/1000).ceilToDouble().toInt() ; l++){
                                times.add(  Expanded(child: Center(child: Text((1+l).toString()))));
                                rows.add(  Expanded( child: Center(child: Container(height: height,width: 2,color: Colors.white,))));
                              }



                              return Stack(
                                children: [
                                  if(showGrid) Container(margin: EdgeInsets.only(top: 28,bottom: 60),
                                    child: Row(
                                      children: rows,
                                    ),
                                  ),
                                  if(showGrid)  Column(
                                    children: [
                                      Row(
                                        children:times,
                                      ),
                                      Container(margin: EdgeInsets.only(top: 10),height: 2,width: double.infinity,color: Colors.white,),

                                    ],
                                  ),

                                  Align(alignment: Alignment.center,child: Container(height: (allAudio.length*74)+23+8,
                                    child: Stack(
                                      children: [
                                        Align(alignment: Alignment.bottomCenter,child: ListView(
                                          shrinkWrap: true,
                                          children: allAudio,
                                        ),),
                                        //allAudioOnly[maxMusicIndex].
                                        StreamBuilder(
                                            stream: allAudioOnly[maxMusicIndex].onAudioPositionChanged,
                                            builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {

                                              Widget  seekbar(int millis){
                                                return  Positioned(bottom: 0,left:(( width*millis/(maxLenght))-30)<0?0:( width*millis/(maxLenght))-30,child: Container(width: 50,height: (allAudio.length*74)+23+8,child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 0),
                                                      child: Text(getMinute(millis),),
                                                    ),
                                                    Container(width: 10,height: 10,color: Colors.orange,),
                                                    Container(width: 2,height: (allAudio.length*74)+3,color: Colors.white,),
                                                  ],
                                                ),));
                                              }
                                              if(snapshot.hasData)
                                                return seekbar(snapshot.data!.inMilliseconds);
                                              else return seekbar(0);

                                            }),





                                      ],
                                    ),
                                  ),),

                                ],
                              );

                            }else{
                              return Center(child: CircularProgressIndicator(),);
                            }
                          }
                      );


                      for(int i = 0 ; i < snapshot.data!.docs.length ; i++){
                        getMusicLenghtOnly(link: snapshot.data!.docs[i].get("file")).then((value) {
                          allDurations.add(value);
                          if(i+1 == snapshot.data!.docs.length){
                            MaxDurationFounndStream.getInstance().dataReload(true);

                          }
                        });


                      }





                      // return Padding(
                      //   padding: const EdgeInsets.only(top: 10),
                      //   child: ListView.builder(
                      //       shrinkWrap: true,
                      //       itemCount: snapshot.data!.docs.length,
                      //       itemBuilder: (BuildContext context, int index) {
                      //         Future<String> downloadFile({required String link})async{
                      //           var url = Uri.parse(snapshot.data!.docs[index].get("wave"));
                      //           var response = await http.get(url);
                      //           Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
                      //           String appDocumentsPath = appDocumentsDirectory.path; // 2
                      //           String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName").toString().replaceAll("mp3", "wave");
                      //           File file = File(filePath);
                      //           await file.writeAsBytes(response.bodyBytes);
                      //           return filePath;
                      //
                      //         }
                      //
                      //         Future<int>getMusicLenght({required String link}) async {
                      //           print("called "+link);
                      //           AudioPlayer advancedPlayer = AudioPlayer();
                      //
                      //           // await  advancedPlayer.setUrl(link);
                      //           advancedPlayer.play(link);
                      //           Duration dd =  await advancedPlayer.onDurationChanged.first;
                      //           return dd.inMilliseconds;
                      //           return  await advancedPlayer.getDuration();
                      //           // return d.inMilliseconds;
                      //
                      //
                      //
                      //         }
                      //         return  FutureBuilder<String>(
                      //           future: downloadFile(link: snapshot.data!.docs[index].get("file")), // async work
                      //           builder: (BuildContext context, AsyncSnapshot<String> snapshotW) {
                      //             switch (snapshotW.connectionState) {
                      //               case ConnectionState.done:
                      //                 return InkWell(onTap: (){
                      //                   Navigator.push(
                      //                     context,
                      //                     MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(wave: snapshotW.data!,link:  snapshot.data!.docs[index].get("file"),width: MediaQuery.of(context).size.width)),
                      //                   );
                      //                 },child: FutureBuilder<int>(
                      //                   future: getMusicLenght(link: snapshot.data!.docs[index].get("file")), // async work
                      //                   builder: (BuildContext context, AsyncSnapshot<int> snapshotD) {
                      //                     if(snapshotD.hasData){
                      //                       return Row(
                      //                         children: [
                      //                           Text((snapshotD.data!).toString()),
                      //                           Container(width: MediaQuery.of(context).size.width-60 , child: SingleAudioGraph(wi: 10,link: snapshotW.data!,)),
                      //
                      //                         ],
                      //                       );
                      //                       return Text((snapshotD.data!).toString());
                      //                     }else{
                      //                       return Text("--");
                      //                     }
                      //                   },
                      //                 ));
                      //               default:
                      //                 if (snapshot.hasError)
                      //                   return Text('Error: ${snapshot.error}');
                      //                 else
                      //                   return Container(height: 0,width: 0,);
                      //                 return Text('Result: ${snapshot.data}');
                      //             }
                      //           },
                      //         );
                      //
                      //         return SingleAudioGraph(wi: 10,link: "",);
                      //         return   ListTile(onTap: () async {
                      //
                      //
                      //           var url = Uri.parse(snapshot.data!.docs[index].get("file"));
                      //           var response = await http.get(url);
                      //           Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
                      //           String appDocumentsPath = appDocumentsDirectory.path; // 2
                      //           String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName");
                      //           File file = File(filePath);
                      //           await file.writeAsBytes(response.bodyBytes);
                      //
                      //
                      //           // Navigator.push(
                      //           //   context,
                      //           //   MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(link: file.path,width: MediaQuery.of(context).size.width)),
                      //           // );
                      //
                      //
                      //         },leading: AudioPlayerWidgetLiveAudio(file: snapshot.data!.docs[index].get("file"),),trailing: IconButton(icon: Icon(Icons.download),onPressed: () async {
                      //           var url = Uri.parse(snapshot.data!.docs[index].get("file"));
                      //           var response = await http.get(url);
                      //           Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
                      //           String appDocumentsPath = appDocumentsDirectory.path; // 2
                      //           String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName");
                      //           File file = File(filePath);
                      //           await file.writeAsBytes(response.bodyBytes);
                      //
                      //
                      //
                      //         },),subtitle: Text(snapshot.data!.docs[index].get("email")),title: Text( snapshot.data!.docs[index].get("fileName")),);
                      //
                      //       }),
                      // );

                    }else{
                      return Center(child: Text("No Tracks"),);
                    }

                  });
            }) ,),


        //ProjectScreenEventStream().projectScreenStream.


      ],
    ),));
  }
}


class AudioPlayerWidgetLiveAudio extends StatefulWidget {
  String file;

  AudioPlayerWidgetLiveAudio({required this.file,});
  AudioPlayer advancedPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  _AudioPlayerWidgetLiveAudioState createState() => _AudioPlayerWidgetLiveAudioState();
}

class _AudioPlayerWidgetLiveAudioState extends State<AudioPlayerWidgetLiveAudio> {
  int durationSecond = 0 ;
  int currrentPosition = 0 ;
  initAudio({required String filePath}) async {

    //final file = File(filePath);
    //widget.advancedPlayer.play(file.path);

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playerStateManagement();
    //initAudio(filePath: widget.file);
  }
  @override
  Widget build(BuildContext context) {


    double prepareData(int c,int d){
      try{
        if((c+d) == 0){
          return 0;
        }else{
          return c/d;
        }

      }catch(e){
        return 0;

      }

    }
    String  getMinute(int min){
      String min_ = "";
      String sec_ = "";
      min_ = (min/60).toInt().toString();
      sec_ = (min%60).toInt().toString();
      if(int.parse(min_)<10)min_ = "0"+min_;
      if(int.parse(sec_)<10)sec_ = "0"+sec_;
      return min_+":"+sec_;
    }
    return Container(height: 60,width: 60,child: Stack(
      children: [
        StreamBuilder<PlayerState>(
            stream: widget. advancedPlayer.onPlayerStateChanged,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                if(snapshot.data == PlayerState.PLAYING){
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.pause();
                  }, icon: Icon(Icons.pause,color: Colors.white,));
                }else if(snapshot.data == PlayerState.COMPLETED){
                  widget.advancedPlayer.stop();

                  currrentPosition = 0;


                  return IconButton(onPressed: (){
                    widget.advancedPlayer.play(widget.file);
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                }else if(snapshot.data == PlayerState.PAUSED){
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.resume();
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                }else if(snapshot.data == PlayerState.STOPPED){

                  currrentPosition = 0;


                  return IconButton(onPressed: (){
                    widget.advancedPlayer.resume();
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                }else{
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.play(widget.file);
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                }

              }else{
                return IconButton(onPressed: (){
                  widget.advancedPlayer.play(widget.file);
                }, icon: Icon(Icons.play_arrow,color: Colors.white,));

              }

            }),
        // Align(alignment: Alignment.bottomCenter,child: Text(getMinute(durationSecond)),),

      ],
    ),);

  }

  void playerStateManagement() {
    widget.advancedPlayer.setUrl(widget.file).then((value) {


      widget.advancedPlayer.onDurationChanged.listen((Duration d) {
        print('Max duration: $d');
        setState(() =>  durationSecond = d.inSeconds);
      });


      widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {

        setState(() => currrentPosition = p.inSeconds)
      });

      // widget.advancedPlayer.getDuration().then((value) {




      // setState(() {
      //   durationSecond = value;
      // });
      // widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {
      //     setState(() => durationSecond = p.inSeconds)
      // });


      // });
    });

  }
}

class AudioPlayerWidgetLiveAudioTime extends StatefulWidget {
  String file;

  AudioPlayerWidgetLiveAudioTime({required this.file,});
  AudioPlayer advancedPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  _AudioPlayerWidgetLiveAudioTimeState createState() => _AudioPlayerWidgetLiveAudioTimeState();
}

class _AudioPlayerWidgetLiveAudioTimeState extends State<AudioPlayerWidgetLiveAudioTime> {
  int durationMillis = 0 ;
  int currrentPositionMillis = 0 ;
  initAudio({required String filePath}) async {

    //final file = File(filePath);
    //widget.advancedPlayer.play(file.path);

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playerStateManagement();
    //initAudio(filePath: widget.file);
  }
  @override
  Widget build(BuildContext context) {


    double prepareData(int c,int d){
      try{
        if((c+d) == 0){
          return 0;
        }else{
          return c/d;
        }

      }catch(e){
        return 0;

      }

    }
    String  getMinute(int min){
      return (durationMillis/1000).toStringAsFixed(1)+" s";
      double min_ = 0;
      double sec_ =0;
      String mm= "";
      String ss= "";
      min_ = (min/60000);
      sec_ = (min%60000);
      if(min_<10)mm = "0"+min_.toStringAsFixed(0);
      if(sec_<10)ss = "0"+sec_.toStringAsFixed(2);
      return ss;
      return mm+":"+ss;
    }
    return Container(height: 60,width: 60,child: Stack(
      children: [
        StreamBuilder<PlayerState>(
            stream: widget. advancedPlayer.onPlayerStateChanged,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                if(snapshot.data == PlayerState.PLAYING){
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.pause();
                  }, icon: Icon(Icons.pause,color: Colors.white,));
                }else if(snapshot.data == PlayerState.COMPLETED){
                  widget.advancedPlayer.stop();

                  currrentPositionMillis = 0;


                  return IconButton(onPressed: (){
                    widget.advancedPlayer.play(widget.file);
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                }else if(snapshot.data == PlayerState.PAUSED){
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.resume();
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                }else if(snapshot.data == PlayerState.STOPPED){

                  currrentPositionMillis = 0;


                  return IconButton(onPressed: (){
                    widget.advancedPlayer.resume();
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                }else{
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.play(widget.file);
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                }

              }else{
                return IconButton(onPressed: (){
                  widget.advancedPlayer.play(widget.file);
                }, icon: Icon(Icons.play_arrow,color: Colors.white,));

              }

            }),
        Align(alignment: Alignment.bottomCenter,child: Text(getMinute(durationMillis)),),

      ],
    ),);

  }

  void playerStateManagement() {
    widget.advancedPlayer.setUrl(widget.file).then((value) {


      widget.advancedPlayer.onDurationChanged.listen((Duration d) {
        print('Max duration: $d');
        setState(() =>  durationMillis = d.inMilliseconds);
      });


      widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {

        setState(() => currrentPositionMillis = p.inSeconds)
      });

      // widget.advancedPlayer.getDuration().then((value) {




      // setState(() {
      //   durationSecond = value;
      // });
      // widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {
      //     setState(() => durationSecond = p.inSeconds)
      // });


      // });
    });

  }
}
class MicForProject extends StatefulWidget {
  bool isProcessing = false;
  Record record = Record();
  String projectId;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String currentrecordingFilePath = "";
  MicForProject({required this.projectId});

  @override
  _MicForProjectState createState() => _MicForProjectState();
}

class _MicForProjectState extends State<MicForProject> {
  bool recording = false;
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  @override
  void dispose() {

    widget.record.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return widget.isProcessing==false? IconButton(icon: Icon(recording?Icons.stop: Icons.fiber_manual_record,color: Colors.white,),onPressed: ()async{
      if(recording){
        if(await widget.record.isRecording())
          widget.record.stop().then((value) {
            widget.record.dispose();
            widget.record = Record();



            print(value);
            setState(() {
              recording = !recording;


            });
            Future.delayed(Duration(seconds: 1)).then((value) async {

              String path =await localPath();
              String  waveFile = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+'waveform.wave';
              print(waveFile);
              setState(() {
                widget.isProcessing = true;
              });


              Stream<WaveformProgress> progressStream = JustWaveform.extract(
                audioInFile: File(widget.currentrecordingFilePath),
                waveOutFile: File(waveFile),
                zoom: const WaveformZoom.pixelsPerSecond(100),
              );

              progressStream.listen((waveformProgress) {

                print('Progress: %${(100 * waveformProgress.progress).toInt()}');
                if (waveformProgress.waveform != null) {

                  //  Waveform? waveform  = waveformProgress.waveform;
                  // Use the waveform.
                  print("use waveform");

                  firebase_storage.Reference refWave = storage.ref(widget.auth.currentUser!.uid+"/"+waveFile.split('/').last);
                  //firebase_storage.Reference ref = storage.ref(fileName);

                  refWave.putFile(File(waveFile)).then((valW) {
                    //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                    refWave.getDownloadURL().then((valueWaveFile) {
                      // String link = await ref.getDownloadURL();
                      print("wave uploaded");


                      firebase_storage.Reference ref = storage.ref(widget.auth.currentUser!.uid+"/"+widget.currentrecordingFilePath.split('/').last);
                      //firebase_storage.Reference ref = storage.ref(fileName);

                      ref.putFile(File(widget.currentrecordingFilePath)).then((val) {
                        //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                        ref.getDownloadURL().then((value) {
                          // String link = await ref.getDownloadURL();
                          print("audio uploaded");
                          // print(link);
                          setState(() {
                            widget.isProcessing = false;
                          });
                          widget.firestore
                              .collection("projects")
                              .doc(widget.projectId).collection("tracks").add({"time":DateTime.now().millisecondsSinceEpoch,"file":value,"wave":valueWaveFile,"email":widget.auth.currentUser!.email,"fileName":widget.currentrecordingFilePath.split('/').last,"uid":widget.auth.currentUser!.uid});
                        });


                      });





                    });


                  });



                }
              });








            });
          });
      }else{
        bool result = await widget.record.hasPermission();
        if(result) {
          String path =await localPath();
          setState(() {
            recording = !recording;


          });
          widget.currentrecordingFilePath =  path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";
          await widget.record.start(
            path:widget.currentrecordingFilePath, // required
            encoder: AudioEncoder.AMR_NB, // by default
            bitRate: 128000, // by default
          );
        }
      }



    },):CircularProgressIndicator(color: Colors.blue,);
  }
}




class Draggablletrack extends StatefulWidget {
  double width;
  double starts;
  Widget widget;

  bool isDraging = false;
  Function(dynamic) onTrackPositionChanged;
  Draggablletrack({required this.width,required this.starts,required this.widget,required this.onTrackPositionChanged});

  @override
  _DraggablletrackState createState() => _DraggablletrackState();
}

class _DraggablletrackState extends State<Draggablletrack> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    makeUpdatedWidget(){
      try{
        return Padding(
            padding:EdgeInsets.only(left: widget.starts),
            child:Container(color: widget.isDraging?Colors.redAccent:Colors.transparent,width: widget.width,child: widget.widget,)
        );


      }catch(e){
        setState(() {
          widget.starts = 0 ;
        });
        print(e);
        return Padding(
            padding:EdgeInsets.only(left: 0),
            child:Container(color: widget.isDraging?Colors.redAccent:Colors.transparent,width: widget.width,child: widget.widget,)
        );
      }
    }

    return Row(
      children: [
        GestureDetector(  onHorizontalDragUpdate: (val){
          //  print("direction "+val.delta.direction.toString());
          //  print("direction "+val.primaryDelta!.toString());


          //print("dragging "+val.delta.toString());
          //  print("dragging "+val.primaryDelta.toString());
          if(val.primaryDelta!>0 && widget.starts+widget.width+2<width) {



            setState(() {
              widget.starts = widget.starts + 1;
              widget.onTrackPositionChanged({"offsetScale":widget.starts/width});
            });
          }else if(val.primaryDelta! < 0 ){
            if( widget.starts - 1>=0)
              setState(() {
                widget.starts = widget.starts - 1;
                widget.onTrackPositionChanged({"offsetScale":widget.starts/width});

              });
            else{
            }

          }else{
          }

        },onHorizontalDragEnd: (val){
          setState(() {
            widget.isDraging = false ;
          });
          //  print("draggingend "+val.velocity.pixelsPerSecond.toString());
          // print("draggingend "+val.primaryVelocity.toString());
        },onHorizontalDragStart: (val){
          setState(() {
            widget.isDraging = true ;
          });
          //  print("draging "+val.localPosition.dx.toString());

        },child: makeUpdatedWidget())
      ],
    );
    return Container(width: widget.width,child: widget.widget,);
    return Stack(children: [
      Positioned(left: widget.starts,child: Container(width: widget.width,child: widget.widget,))
    ],);
  }
}


class SingleAudioGraph extends StatefulWidget {
  String link;
  double wi;

  SingleAudioGraph({required this.link,required this.wi});
  AudioPlayer advancedPlayer = AudioPlayer();
  bool isPlaying = false;
  int progress = 0 ;

  bool isReady = false;

  double currrentPositionLeftOffset =20;


  @override
  _SingleAudioGraphState createState() => _SingleAudioGraphState();

}

class _SingleAudioGraphState extends State<SingleAudioGraph> {
  late Stream<WaveformProgress> progressStream;
  String waveFile = "";
  late Waveform waveform;
  double width = 600;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    prepareData();
    playerStateManagement();

    //initAudio(filePath: widget.file);
  }
  void playerStateManagement() {
    width =  width-40;
    print("width "+width.toString());

    widget.advancedPlayer.setUrl(widget.link).then((value) {


      widget.advancedPlayer.onDurationChanged.listen((Duration d) {
        print('Max duration: $d');
        if(mounted) setState(() { durationMillis = d.inMilliseconds;});
      });


      widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {

        if(mounted) setState(() {
          currrentPosition = p.inSeconds;
          int  currentPosInMillis = p.inMilliseconds;

          widget.currrentPositionLeftOffset =20+(width)*(((((currentPosInMillis)*1))/(durationMillis)));
          print("calculated offset "+widget.currrentPositionLeftOffset.toString());




        })
      });

      // widget.advancedPlayer.getDuration().then((value) {




      // setState(() {
      //   durationSecond = value;
      // });
      // widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {
      //     setState(() => durationSecond = p.inSeconds)
      // });


      // });
    });

  }
  //int durationSecond = 0 ;
  int durationMillis = 0 ;
  int currrentPosition = 0 ;

  initAudio({required String filePath}) async {

    //final file = File(filePath);
    //widget.advancedPlayer.play(file.path);

  }
  prepareData() async {
    String path =await localPath();
    waveFile = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+'waveform.wave';
    print(waveFile);
    waveform =  await  JustWaveform.parse(File(widget.link));
    setState(() {
      widget.isReady = true ;
    });


    // progressStream = JustWaveform.extract(
    //   audioInFile: File(widget.link),
    //   waveOutFile: File(waveFile),
    //   zoom: const WaveformZoom.pixelsPerSecond(100),
    // );
    //
    //
    // progressStream.listen((waveformProgress) {
    //   setState(() {
    //     widget.progress = (100 * waveformProgress.progress).toInt();
    //   });
    //   print('Progress: %${(100 * waveformProgress.progress).toInt()}');
    //   if (waveformProgress.waveform != null) {
    //
    //     waveform = waveformProgress.waveform!;
    //     // Use the waveform.
    //     print("use waveform");
    //     setState(() {
    //       widget.isReady = true ;
    //     });
    //   }
    // });
    //  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    // _flutterFFmpeg.execute("ffmpeg -i input -filter_complex 'showwavespic=s=640x120' -frames:v 1 output.png").then((rc) => print("FFmpeg process exited with rc $rc"));
    // var url = Uri.parse(widget.link);
    // var response = await http.get(url);
    // Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    // String appDocumentsPath = appDocumentsDirectory.path; // 2
    // String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName");
    // File file = File(filePath);
    // await file.writeAsBytes(response.bodyBytes);

  }
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    String  getMinute(int min){
      String min_ = "";
      String sec_ = "";
      min_ = (min/60).toInt().toString();
      sec_ = (min%60).toInt().toString();
      if(int.parse(min_)<10)min_ = "0"+min_;
      if(int.parse(sec_)<10)sec_ = "0"+sec_;
      return min_+":"+sec_;
    }
    String  getMinuteMillis(int millis){
      String min_ = "";
      String sec_ = "";
      min_ = (millis/60000).toInt().toString();
      sec_ = (millis%60000).toInt().toString();
      if(int.parse(min_)<10)min_ = "0"+min_;
      if(int.parse(sec_)<10)sec_ = "0"+sec_;
      return min_+":"+sec_;
    }
    showImage2(){
      double perpixWidth = width/waveform.length;
      double wholeHeight = 70;
      List<Widget> allColumns = [];
      int  maxVal = 0;
      return StreamBuilder<Duration>(
          stream: widget.advancedPlayer.onAudioPositionChanged,
          builder: (c, snapshot) {
            if(snapshot.hasData){
              for(int i = 0 ; i < waveform.length ; i ++){
                if(maxVal<waveform[i].abs()){
                  maxVal = waveform[i].abs();
                }
              }
              for(int i = 0 ; i <waveform.length ; i ++){
                if((snapshot.data!.inMilliseconds/durationMillis )<i/waveform.length)
                  allColumns.add(Expanded(child: Container(height: (waveform[i].abs()/maxVal)*wholeHeight,color: Colors.grey,)));
                else
                  allColumns.add(Expanded(child: Container(height: (waveform[i].abs()/maxVal)*wholeHeight,color: Colors.blue,)));

              }

              return Row(
                children: allColumns,
              );
            }else{
              for(int i = 0 ; i < waveform.length ; i ++){
                if(maxVal<waveform[i].abs()){
                  maxVal = waveform[i].abs();
                }
              }
              for(int i = 0 ; i <waveform.length ; i ++){
                allColumns.add(Expanded(child: Container(height: (waveform[i].abs()/maxVal)*wholeHeight,color: Colors.grey,)));
              }

              return Row(
                children: allColumns,
              );

            }


          });
      return  Container(height: 70,width: widget.wi,
        child: Padding(
          padding: const EdgeInsets.only(top: 5,bottom: 5),
          child:  AudioWaveformWidget(
            waveform: waveform,
            start: Duration.zero,
            duration: waveform.duration,
          ),
        ),
      );

    }
    showImage(){
      int maxVal = 0 ;

      //  double width = width ;
      double perpixWidth = width/waveform.length;
      double wholeHeight = 70;
      List<Widget> allColumns = [];
      // int itemsToMap =  waveform.length;
      int itemsToMap =  70;
      int samplingFactor = (waveform.length/(80*(widget.wi/width))*(1)).toInt();
      //samplingFactor = (samplingFactor/3).ceilToDouble().toInt();

      try{
        //samplingFactor = ((widget.wi/width)*samplingFactor).ceilToDouble().toInt();
      }catch(e){
        print(e);
      }

      List<int> reSampledList = [];

      for(int i = 0 ; i < waveform.length; i = i+samplingFactor){
        int tempValue = 0;
        for(int j = 0 ; j <samplingFactor ; j++ ){
          tempValue = waveform[i+samplingFactor];
        }

        try{
          reSampledList.add((tempValue/samplingFactor).toInt());
        }catch(e){
          reSampledList.add(1);
        }





      }
      Text(reSampledList.length.toString());
      for(int i = 0 ; i < reSampledList.length ; i ++){
        if(maxVal<reSampledList[i].abs()){
          maxVal = reSampledList[i].abs();
        }
      }
      return StreamBuilder<Duration>(
          stream: widget.advancedPlayer.onAudioPositionChanged,
          builder: (c, snapshot) {
            if(snapshot.hasData){


              for(int i = 0 ; i <reSampledList.length ; i ++){
                if((snapshot.data!.inMilliseconds/durationMillis )<=i/reSampledList.length)
                  allColumns.add(Expanded(child: Container(height: (reSampledList[i].abs()/maxVal)*wholeHeight,color: Colors.white,)));
                else
                  allColumns.add(Expanded(child: Container(height: (reSampledList[i].abs()/maxVal)*wholeHeight,color: Colors.blue,)));

              }

              return Row(
                children: allColumns,
              );
            }else{

              for(int i = 0 ; i <reSampledList.length ; i ++){
                allColumns.add(Expanded(child: Container(height: (reSampledList[i].abs()/maxVal)*wholeHeight,color: Colors.white,)));
              }

              return Row(
                children: allColumns,
              );

            }


          });







      return  Container(height: 90,width: MediaQuery.of(context).size.width,
        child: AudioWaveformWidget(waveColor: Colors.red,
          waveform: waveform,
          start: Duration(seconds: 1),
          duration: waveform.duration,
        ),
      );

    }
    Text("ok");

    return widget.isReady?Container(margin: EdgeInsets.only(top: 2,left: 2,right: 2,bottom: 2),child: Container(decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(5)
    ),child: showImage(),),):Container(child:Center(child: CircularProgressIndicator())  ,);
    return WillPopScope (
      onWillPop: () async {
        return true;
      },
      child:SafeArea(child: Scaffold(appBar: AppBar(),body: Stack(
        children: [
          Align(alignment: Alignment.center,child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10,),),
            margin: EdgeInsets.all(0),height: 125,
            child: Stack(children: [
              Align(alignment: Alignment.bottomCenter,child:
              widget.isReady?Container(margin: EdgeInsets.only(top: 20,left: 20,right: 20),child: showImage(),):Container(child:Center(child: CircularProgressIndicator())  ,) ,),


              Align(alignment: Alignment.bottomCenter,child: Opacity(opacity: 0.3,
                child: Container(margin: EdgeInsets.only(top: 20,left: 20,right: 20),
                  child: StreamBuilder<Duration>(
                      stream:  widget.advancedPlayer.onAudioPositionChanged,
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          if(snapshot.data == durationMillis)return   Container(

                            width: width,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: 0,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(
                                    0x22ff0000)),
                                backgroundColor: Color(0xffD6D6D6),
                              ),
                            ),
                          );
                          else  return  Container(

                            width: width,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: snapshot.data!.inMilliseconds/(durationMillis),
                                valueColor: AlwaysStoppedAnimation<Color>(Color(
                                    0x22ff0000)),
                                backgroundColor: Color(0xffD6D6D6),
                              ),
                            ),
                          );
                          // else  return LinearProgressIndicator(minHeight: 100,color: Colors.blue.withOpacity(0.5),value: snapshot.data!.inMilliseconds/(durationSecond*1000),);
                          return Text(snapshot.data!.inSeconds.toString());

                        }else{
                          return Container(

                            width: width,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: 0,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(
                                    0x22ff0000)),
                                backgroundColor: Color(0xffD6D6D6),
                              ),
                            ),
                          );
                        }

                      }),
                ),
              ) ,),
              Positioned(left:widget.currrentPositionLeftOffset-25,child: Container(width: 50,
                child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(child: Text(getMinute(currrentPosition))),
                    CircleAvatar(radius: 5,backgroundColor: Colors.black,),
                    Container(  height: 130,width: 2,color: Colors.black,)
                  ],
                ),
              ),),
            ],),
          ) ,),

          Align(alignment: Alignment.bottomCenter,child: Container(margin: EdgeInsets.only(bottom: 15),child:Card(elevation: 5,color: Colors.blue,shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),child: Container(width: 60,height: 60,child: Center(child: StreamBuilder<PlayerState>(
              stream: widget. advancedPlayer.onPlayerStateChanged,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  if(snapshot.data == PlayerState.PLAYING){
                    return IconButton(onPressed: (){
                      widget.advancedPlayer.pause();
                    }, icon: Icon(Icons.pause,color: Colors.white,));
                  }else if(snapshot.data == PlayerState.COMPLETED){
                    widget.advancedPlayer.stop();

                    currrentPosition = 0;


                    return IconButton(onPressed: (){
                      widget.advancedPlayer.play(widget.link);
                    }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                  }else if(snapshot.data == PlayerState.PAUSED){
                    return IconButton(onPressed: (){
                      widget.advancedPlayer.resume();
                    }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                  }else if(snapshot.data == PlayerState.STOPPED){

                    currrentPosition = 0;


                    return IconButton(onPressed: (){
                      widget.advancedPlayer.resume();
                    }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                  }else{
                    return IconButton(onPressed: (){
                      widget.advancedPlayer.play(widget.link);
                    }, icon: Icon(Icons.play_arrow,color: Colors.white,));
                  }

                }else{
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.play(widget.link);
                  }, icon: Icon(Icons.play_arrow,color: Colors.white,));

                }

              }),),),) ,),),
          // Container(width: MediaQuery.of(context).size.width,height: 60,
          //   child: Center(
          //     child: Row(
          //       children: [
          //         Container(width: 60,height: 60,child: Center(child: StreamBuilder<PlayerState>(
          //             stream: widget. advancedPlayer.onPlayerStateChanged,
          //             builder: (context, snapshot) {
          //               if(snapshot.hasData){
          //                 if(snapshot.data == PlayerState.PLAYING){
          //                   return IconButton(onPressed: (){
          //                     widget.advancedPlayer.pause();
          //                   }, icon: Icon(Icons.pause));
          //                 }else if(snapshot.data == PlayerState.COMPLETED){
          //                   widget.advancedPlayer.stop();
          //
          //                   currrentPosition = 0;
          //
          //
          //                   return IconButton(onPressed: (){
          //                     widget.advancedPlayer.play(widget.link);
          //                   }, icon: Icon(Icons.play_arrow));
          //                 }else if(snapshot.data == PlayerState.PAUSED){
          //                   return IconButton(onPressed: (){
          //                     widget.advancedPlayer.resume();
          //                   }, icon: Icon(Icons.play_arrow));
          //                 }else if(snapshot.data == PlayerState.STOPPED){
          //
          //                   currrentPosition = 0;
          //
          //
          //                   return IconButton(onPressed: (){
          //                     widget.advancedPlayer.resume();
          //                   }, icon: Icon(Icons.play_arrow));
          //                 }else{
          //                   return IconButton(onPressed: (){
          //                     widget.advancedPlayer.play(widget.link);
          //                   }, icon: Icon(Icons.play_arrow));
          //                 }
          //
          //               }else{
          //                 return IconButton(onPressed: (){
          //                   widget.advancedPlayer.play(widget.link);
          //                 }, icon: Icon(Icons.play_arrow));
          //
          //               }
          //
          //             }),),),
          //         Column(mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(widget.link.split('/').last),
          //             Text(getMinute(durationSecond)),
          //           ],
          //         )
          //
          //
          //         // StreamBuilder<Duration>(
          //         // stream:  widget.advancedPlayer.onAudioPositionChanged,
          //         // builder: (context, snapshot) {
          //         // if(snapshot.hasData){
          //         //   return Padding(
          //         //     padding: const EdgeInsets.all(8.0),
          //         //     child: Slider(min: 0.0,
          //         //       max: 100.0,value: (100*snapshot.data!.inSeconds)/durationSecond,onChanged: (val){
          //         //         setState(() {
          //         //           currrentPosition =( (val*durationSecond) as int)*100;
          //         //         });
          //         //
          //         //       },),
          //         //   );
          //         //   return Text(snapshot.data!.inSeconds.toString());
          //         //
          //         // }else{
          //         //   return Text("Wait");
          //         // }
          //         //
          //         // }),
          //
          //
          //       ],
          //     ),
          //   ),
          // ),
          // AudioPlayerWidgetButtonOnly(file: widget.link,),
        ],
      ),)) ,
    );
    //&& snapshot.connectionState == ConnectionState.active
    // Center(
    //   child: StreamBuilder<WaveformProgress>(
    //       stream: progressStream.listen,
    //       builder: (BuildContext context, AsyncSnapshot<WaveformProgress> snapshot) {
    //         if(snapshot.hasData){
    //           return Text( (100 * snapshot.data!.progress).toInt().toString());
    //         }else{
    //           return Container(height: 0,width: 0,);
    //         }
    //       }),
    // );

    //ffmpeg -i input -filter_complex "showwavespic=s=640x120" -frames:v 1 output.png

  }
}

String  getMinute(int min){
  double min_ = 0;
  double sec_ =0;
  String mm= "";
  String ss= "";
  // min_ = (min/60000);
  sec_ = (min/1000);
  if(min_<10)mm = "0"+min_.toStringAsFixed(0);
  if(sec_<10)ss = sec_.toStringAsFixed(2);
  return ss;
  return mm+":"+ss;
}

class AudioWaveformWidget extends StatefulWidget {
  final Color waveColor;
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  const AudioWaveformWidget({
    Key? key,
    required this.waveform,
    required this.start,
    required this.duration,
    this.waveColor = Colors.blue,
    this.scale = 10.0,
    this.strokeWidth = 1.0,
    this.pixelsPerStep = 2,
  }) : super(key: key);

  @override
  _AudioWaveformState createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveformWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: AudioWaveformPainter(
          waveColor: widget.waveColor,
          waveform: widget.waveform,
          start: widget.start,
          duration: widget.duration,
          scale: widget.scale,
          strokeWidth: widget.strokeWidth,
          pixelsPerStep: widget.pixelsPerStep,
        ),
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Paint wavePaint;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  AudioWaveformPainter({
    required this.waveform,
    required this.start,
    required this.duration,
    Color waveColor = Colors.blue,
    this.scale = 1.0,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
  }) : wavePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..color = waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (duration == Duration.zero) return;

    double width = size.width;
    double height = size.height;

    final waveformPixelsPerWindow = waveform.positionToPixel(duration).toInt();
    final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
    final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;
    final sampleOffset = waveform.positionToPixel(start);
    final sampleStart = -sampleOffset % waveformPixelsPerStep;
    for (var i = sampleStart.toDouble();
    i <= waveformPixelsPerWindow + 1.0;
    i += waveformPixelsPerStep) {
      final sampleIdx = (sampleOffset + i).toInt();
      final x = i / waveformPixelsPerDevicePixel;
      final minY = normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = normalise(waveform.getPixelMax(sampleIdx), height);
      canvas.drawLine(
        Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
        Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return false;
  }

  double normalise(int s, double height) {
    if (waveform.flags == 0) {
      final y = 32768 + (scale * s).clamp(-32768.0, 32767.0).toDouble();
      return height - 1 - y * height / 65536;
    } else {
      final y = 128 + (scale * s).clamp(-128.0, 127.0).toDouble();
      return height - 1 - y * height / 256;
    }
  }
}