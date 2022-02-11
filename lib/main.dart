import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audio/utils/appConst.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

import 'Auth/Service/AuthRepository.dart';
import 'Auth/Service/AuthStatus.dart';
import 'Auth/View/ui.dart';
import 'Home/View/ui.dart';
import 'Home/bLoc/bloc.dart';
import 'Project/bLoc/bloc.dart';
import 'UploadAudio/bLoc/bloc.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 25, 0, 36)
  ));
  HomeScreenBloc().startListen();
  UploadAudioScreenBloc().startListen();
  ProjectScreenBloc().startListen();
  runApp(MaterialApp(debugShowCheckedModeBanner: false,theme: ThemeData(textTheme: TextTheme(
    bodyText1: TextStyle(color: Colors.white),bodyText2: TextStyle(color: Colors.white),
  ),primaryColor: Colors.white,accentColor: Colors.white,cursorColor: Colors.white,inputDecorationTheme: InputDecorationTheme(
    border: const OutlineInputBorder(
      // width: 0.0 produces a thin "hairline" border
      borderSide: const BorderSide(color: Colors.white, width: 0.0),
    ),
    enabledBorder: const OutlineInputBorder(
      // width: 0.0 produces a thin "hairline" border
      borderSide: const BorderSide(color: Colors.white, width: 0.0),
    ),
    disabledBorder:  const OutlineInputBorder(
      // width: 0.0 produces a thin "hairline" border
      borderSide: const BorderSide(color: Colors.white, width: 0.0),
    ),
    focusedBorder:   const OutlineInputBorder(
      // width: 0.0 produces a thin "hairline" border
      borderSide: const BorderSide(color: Colors.white, width: 0.0),
    ),
    labelStyle: TextStyle(
        color:Colors.white,
        fontSize: 18.0
    ),
  ),appBarTheme: AppBarTheme(color: Color.fromARGB(255, 25, 0, 36)),scaffoldBackgroundColor: Color.fromARGB(255, 25, 0, 36)),navigatorKey: navigatorKey,home:MyApp() ,) );
}
double appbarHeight = 0;
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    //HomeScreenBloc().startListen();
    return StreamBuilder<AuthState>(
        stream: AppAuth().getInstance()!.checkAuth(),
        builder: (c, snapshotAuth) {
          print(snapshotAuth.data);
          if(snapshotAuth.hasData){
            if(snapshotAuth.data! == AuthState.authenticatedUser){
              return HomeUI().Screen();
            }else  if(snapshotAuth.data! == AuthState.unauthenticated){
              return LoginUI().Screen();
            }else return Scaffold(body: Center(child: CircularProgressIndicator(),),);
          }else return Scaffold(body: Center(child: CircularProgressIndicator(),),);


        });

  }
}



















class FFmpeg {



}
Future<File> concatenate(List<String> assetPaths, {String output = "new.mp3"})async{
  print("all");
  print(assetPaths);
  // String fileOne = assetPaths[0];
  // String fileTwo = assetPaths[1];
  //
  // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  // _flutterFFmpeg.execute("ffmpeg -i $fileOne -i $fileTwo -i file3.mp3 -filter complex amerge $output").then((rc) => print("FFmpeg process exited with rc $rc"));
  // print(output);


 // final directory = await getTemporaryDirectory();
  //final file = File("${directory.path}/$output");
  final file = File(output);

  final ffm = FlutterFFmpeg();
  final cmd = ["-y"];
  for(var path in assetPaths){
    try{
      final tmp = await copyToTemp(path);
      cmd.add("-i");
      cmd.add(tmp.path);
      print("payer pass");
    }catch(e){
      print("payer");
      print(e);
    }
  }

  try{
    cmd.addAll([
      "-filter_complex",
      "[0:a] [1:a] concat=n=${assetPaths.length}:v=0:a=1 [a]",
      "-map", "[a]", "-c:a", "libmp3lame", file.path
    ]);
    print("passed this");
  }catch(e){
    print("thi");

    print("thi2");
  }



  try{
    await ffm.executeWithArguments(cmd);
    print("passed last");
  }catch(e){
    print("sury");
    print(e);

  }

  print("returning file");
  print(file.path);


  return file;
}

Future<File>copyToTemp(String path)async{
  print("working "+path);
 // Directory tempDir = await getTemporaryDirectory();
  final tempFile = File(path);
  if(await tempFile.exists()){
    print("File was availablae");
    return tempFile;
  }
  final bd = await rootBundle.load(path);
  await tempFile.writeAsBytes(bd.buffer.asUint8List(), flush: true);
  return tempFile;
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
          child:Container(color: widget.isDraging?Colors.white:Colors.transparent,width: widget.width,child: widget.widget,)
        );


      }catch(e){
        setState(() {
          widget.starts = 0 ;
        });
        print(e);
        return Padding(
            padding:EdgeInsets.only(left: 0),
            child:Container(color: widget.isDraging?Colors.white:Colors.transparent,width: widget.width,child: widget.widget,)
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

