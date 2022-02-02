import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
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
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
double appbarHeight = 0;
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Container(color: Colors.white,child: SafeArea(child: Scaffold(body: StreamBuilder(
          stream: UserLoggedInStream.getInstance().outData,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            print("auth changed");
            appbarHeight = MediaQuery.of(context).padding.top + kToolbarHeight ;
            TextEditingController controller1 = TextEditingController();
            TextEditingController controller2 = TextEditingController();

            return StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                  //&& snapshot.connectionState == ConnectionState.active
                  if (snapshot.data?.uid == null ) {
                    //  return SplineArea();
                    //  LoginScreen();
                    // return LoginScreen(locale: widget.locale,
                    //   auth: _auth,
                    //   firestore: _firestore,
                    // );
                    return Scaffold(body: Center(
                      child: Container(height: 400,child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(decoration: InputDecoration(
                            hintText: "Email",contentPadding: EdgeInsets.all(10)
                          ),controller: controller1,),
                          TextFormField(decoration: InputDecoration(
                              hintText: "Password",contentPadding: EdgeInsets.all(10)
                          ),controller: controller2,),
                          Container(decoration: BoxDecoration(color: Colors.redAccent,borderRadius: BorderRadius.circular(4)),margin: EdgeInsets.all(15),child: InkWell(onTap: (){
                            FirebaseAuth.instance.signInWithEmailAndPassword(email: controller1.text, password: controller2.text).then((value) {
                              UserLoggedInStream.getInstance().dataReload(true);
                            });
                          },child:Center(child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text("Login",),
                          ),),),)
                        ],
                      ),),
                    ),);
                  } else if (snapshot.data?.uid != null ){
                    // return YouAreGenuser(
                    //   auth: _auth,
                    //   firestore: _firestore,
                    // );

                    return MyHomePage();

                  }
                  return Scaffold(body: Center(child: Text("Please wait"),),);


                }
              //Auth stream
            );
          }),)),),
    );
  }
}

class MyHomePage extends StatefulWidget {
  Record record = Record();


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
Future<String>  localPath() async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool recording = false ;


  String? directory;
  List file = [];
  List fileBool = [];
  List positiveSelectedFiles = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listofFiles();
  }
  // Make New Function
  void _listofFiles() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      positiveSelectedFiles.clear();
      file.clear();
      fileBool.clear();
      file = io.Directory("$directory/").listSync();

      for(int i = 0 ; i < file.length ; i++){
        if(file[i].path.endsWith(".mp3")){
          fileBool.add({"path":file[i].path,"selected":false});


        }

        //sync file


       for(int i = 0 ; i < fileBool.length ; i++){

         firestore
             .collection("all")
             .doc((fileBool[i]["path"].split('/').last).toString().replaceAll(".mp3", "")).get().then((value) {
            if(value.exists){
              //others audio
            }   else{
              firebase_storage.Reference ref = storage.ref(auth.currentUser!.uid+"/"+fileBool[i]["path"].split('/').last);
              //firebase_storage.Reference ref = storage.ref(fileName);

              ref.putFile(File(fileBool[i]["path"])).then((val) {
                //await  ref.putFile(File(allPHotos[i]["imagePath"]));

                ref.getDownloadURL().then((value) {
                  // String link = await ref.getDownloadURL();
                  print("download link");
                  // print(link);
                  firestore
                      .collection("all")
                      .doc((fileBool[i]["path"].split('/').last).toString().replaceAll(".mp3", "")).set({"uid":auth.currentUser!.uid,"email":auth.currentUser!.email,"fileName":fileBool[i]["path"].split('/').last,"link":value});
                  firestore
                      .collection(auth.currentUser!.uid)
                      .doc((fileBool[i]["path"].split('/').last).toString().replaceAll(".mp3", "")).set({"uid":auth.currentUser!.uid,"email":auth.currentUser!.email,"fileName":fileBool[i]["path"].split('/').last,"link":value});
                });


              });
            }
         });






       }

      }
    });
  }

  void setFiles(){
    positiveSelectedFiles.clear();
    for(int i = 0 ; i < fileBool.length ; i++){
      if(fileBool[i]["selected"] == true){
        positiveSelectedFiles.add(fileBool[i]["path"] );
      }

    }
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return DefaultTabController(
      length: 2,
      child: Scaffold( floatingActionButton: FloatingActionButton(
        onPressed: () async {

          if(recording){
            if(await widget.record.isRecording())
              widget.record.stop().then((value) {
                print(value);
                setState(() {
                  recording = !recording;


                });
                Future.delayed(Duration(seconds: 1)).then((value) {
                  _listofFiles();

                });
              });
          }else{
            bool result = await widget.record.hasPermission();
            if(result) {
              String path =await localPath();
              setState(() {
                recording = !recording;


              });
              await widget.record.start(
                path: path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3", // required
                encoder: AudioEncoder.AMR_NB, // by default
                bitRate: 128000, // by default
              );
            }
          }



        },
        tooltip: 'Record',
        child:  Icon(recording?Icons.stop: Icons.mic),
      ),
        appBar: AppBar(  title: Text("Audio Mate"),actions: [

          if(false) IconButton(onPressed: () async {
            List<String> filesSt = [];

            for(int i = 0 ; i< file.length;i++){
              if(file[i].path.endsWith(".mp3"))

                filesSt.add(file[i].path);
            }

            fuseAudio(List<String> datas) async {
              print("total file "+datas.length.toString());
              String path =await localPath();
              try{
                String fileName = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";

                //String fileName = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";



                // String fileOne = datas[0];
                // String fileTwo = datas[1];
                // String command ="ffmpeg -i $fileOne -i $fileTwo -filter complex amerge $fileName";
                // print(command);
                //
                // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
                // File ff = File(fileName);
                // print(ff.path);
                // //ff.writeAsString('xxx');
                // String pp = ff.path;
                // print(pp);


                // _flutterFFmpeg.execute("-i $fileOne -i $fileTwo -c copy $pp")
                //     .then((return_code) => print("Return code $return_code"));

                // _flutterFFmpeg.execute(command).then((rc) => print("FFmpeg process exited with rc $rc"));
                // print(output);

                await concatenate(
                    datas,output: fileName

                );
                // print(track);
                // print(await track.exists());
                // print("got file "+track.path);

                //file.add(fileName);
                //setState(() {
                //file.add(fileName);
                //fileBool.add({"path":fileName,"selected":false});

                //  });
                _listofFiles();
              }catch(e){
                //  setState(() {


                //  });
                _listofFiles();
                print("concat error");
                print(e);
              }

            }

            fuseAudio(filesSt);




          }, icon: Icon(Icons.save)),
          if(positiveSelectedFiles.length>0) IconButton(onPressed: () async {


            for(int i = 0 ; i< positiveSelectedFiles.length;i++){
              File f = File(positiveSelectedFiles[i]);
              try{
                await f.delete();
                firebase_storage.Reference ref = storage.ref(auth.currentUser!.uid+"/"+positiveSelectedFiles[i].split('/').last);
                ref.delete();
                
                firestore.collection("all").doc((positiveSelectedFiles[i].split('/').last).toString().replaceAll(".mp3", "")).delete();
                firestore.collection(auth.currentUser!.uid).doc((positiveSelectedFiles[i].split('/').last).toString().replaceAll(".mp3", "")).delete();

                setState(() {
                  _listofFiles();
                });
              }catch(e){
                setState(() {
                  _listofFiles();
                });
              }

            }







          }, icon: Icon(Icons.delete)),
          IconButton(onPressed: () async {


            auth.signOut();
            UserLoggedInStream.getInstance().dataReload(true);






          }, icon: Icon(Icons.logout))


        ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.save)),
              Tab(icon: Icon(Icons.cloud)),
            ],
          ),
        ),
        body:   TabBarView(
          children: [
            Column(
              children: [
                ListView.builder(shrinkWrap: true,
                    itemCount: fileBool.length,
                    itemBuilder: (BuildContext context, int index) {
                      if(fileBool[index]["path"].endsWith(".mp3"))
                        return AudioPlayerWidget(file:fileBool[index]["path"] ,selected:fileBool[index]["selected"] ,isSelected: (val){


                          fileBool[index]["selected"] = val;

                          setFiles();




                        });


                      //return Text(file[index].path);
                      else return Container(height: 0,width: 0,);
                    }),
                if(positiveSelectedFiles.length>1) InkWell(onTap: (){

                  List<String> filesSt = [];

                  for(int i = 0 ; i< positiveSelectedFiles.length;i++){

                    filesSt.add(positiveSelectedFiles[i]);
                  }

                  fuseAudio(List<String> datas) async {
                    print("total file "+datas.length.toString());
                    String path =await localPath();
                    try{
                      String fileName = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";

                      //String fileName = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";



                      // String fileOne = datas[0];
                      // String fileTwo = datas[1];
                      // String command ="ffmpeg -i $fileOne -i $fileTwo -filter complex amerge $fileName";
                      // print(command);
                      //
                      // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
                      // File ff = File(fileName);
                      // print(ff.path);
                      // //ff.writeAsString('xxx');
                      // String pp = ff.path;
                      // print(pp);


                      // _flutterFFmpeg.execute("-i $fileOne -i $fileTwo -c copy $pp")
                      //     .then((return_code) => print("Return code $return_code"));

                      // _flutterFFmpeg.execute(command).then((rc) => print("FFmpeg process exited with rc $rc"));
                      // print(output);

                      await concatenate(
                          datas,output: fileName

                      );
                      // print(track);
                      // print(await track.exists());
                      // print("got file "+track.path);

                      //file.add(fileName);
                      //setState(() {
                      //file.add(fileName);
                      //fileBool.add({"path":fileName,"selected":false});

                      //  });
                      _listofFiles();
                    }catch(e){
                      //  setState(() {


                      //  });
                      _listofFiles();
                      print("concat error");
                      print(e);
                    }

                  }

                  fuseAudio(filesSt);
                },child: Container(margin: EdgeInsets.all(15),decoration: BoxDecoration(color: Colors.redAccent,borderRadius: BorderRadius.circular(5)),width: MediaQuery.of(context).size.width,height: 50,child: Center(child: Text("Merge Audio sequentialy"),),)),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
            stream: firestore.collection("all").where("uid",isNotEqualTo: auth.currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return  ListView.builder(shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                   return ListTile(onTap: () async {


                     var url = Uri.parse(snapshot.data!.docs[index].get("link"));
                     var response = await http.get(url);
                     Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
                     String appDocumentsPath = appDocumentsDirectory.path; // 2
                     String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName");
                     File file = File(filePath);
                     await file.writeAsBytes(response.bodyBytes);
                     _listofFiles();

                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(link: file.path,)),
                     );


                   },leading: AudioPlayerWidgetLiveAudio(file: snapshot.data!.docs[index].get("link"),),trailing: IconButton(icon: Icon(Icons.download),onPressed: () async {
                     var url = Uri.parse(snapshot.data!.docs[index].get("link"));
                     var response = await http.get(url);
                     Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
                     String appDocumentsPath = appDocumentsDirectory.path; // 2
                     String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName");
                     File file = File(filePath);
                     await file.writeAsBytes(response.bodyBytes);
                     _listofFiles();

                     
                   },),subtitle: Text(snapshot.data!.docs[index].get("email")),title: Text( snapshot.data!.docs[index].get("fileName")),);
                        return AudioPlayerWidget(file:fileBool[index]["path"] ,selected:fileBool[index]["selected"] ,isSelected: (val){


                          fileBool[index]["selected"] = val;

                          setFiles();




                        });


                     
                    });
              }else{
                return Container(height: 0,width: 0,);
              }
            }),

          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Audio Mate"),
        actions: [

         if(false) IconButton(onPressed: () async {
            List<String> filesSt = [];

            for(int i = 0 ; i< file.length;i++){
              if(file[i].path.endsWith(".mp3"))

              filesSt.add(file[i].path);
            }

            fuseAudio(List<String> datas) async {
              print("total file "+datas.length.toString());
              String path =await localPath();
             try{
               String fileName = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";

               //String fileName = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";



               // String fileOne = datas[0];
               // String fileTwo = datas[1];
               // String command ="ffmpeg -i $fileOne -i $fileTwo -filter complex amerge $fileName";
               // print(command);
               //
               // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
               // File ff = File(fileName);
               // print(ff.path);
               // //ff.writeAsString('xxx');
               // String pp = ff.path;
               // print(pp);


               // _flutterFFmpeg.execute("-i $fileOne -i $fileTwo -c copy $pp")
               //     .then((return_code) => print("Return code $return_code"));

              // _flutterFFmpeg.execute(command).then((rc) => print("FFmpeg process exited with rc $rc"));
              // print(output);

                await concatenate(
                   datas,output: fileName

               );
              // print(track);
              // print(await track.exists());
              // print("got file "+track.path);

               //file.add(fileName);
               //setState(() {
                 //file.add(fileName);
                 //fileBool.add({"path":fileName,"selected":false});

             //  });
               _listofFiles();
             }catch(e){
             //  setState(() {


             //  });
               _listofFiles();
               print("concat error");
               print(e);
             }

            }

            fuseAudio(filesSt);




          }, icon: Icon(Icons.save)),
         if(positiveSelectedFiles.length>0) IconButton(onPressed: () async {


            for(int i = 0 ; i< positiveSelectedFiles.length;i++){
              File f = File(positiveSelectedFiles[i]);
             try{
               await f.delete();
               setState(() {
                 _listofFiles();
               });
             }catch(e){
               setState(() {
                 _listofFiles();
               });
             }

            }







          }, icon: Icon(Icons.delete))
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: [
            ListView.builder(shrinkWrap: true,
                itemCount: fileBool.length,
                itemBuilder: (BuildContext context, int index) {
                 if(fileBool[index]["path"].endsWith(".mp3"))
                   return AudioPlayerWidget(file:fileBool[index]["path"] ,selected:fileBool[index]["selected"] ,isSelected: (val){


                       fileBool[index]["selected"] = val;

                       setFiles();




                     });


                  //return Text(file[index].path);
                  else return Container(height: 0,width: 0,);
                }),
            if(positiveSelectedFiles.length>1) InkWell(onTap: (){

              List<String> filesSt = [];

            for(int i = 0 ; i< positiveSelectedFiles.length;i++){

                filesSt.add(positiveSelectedFiles[i]);
            }

            fuseAudio(List<String> datas) async {
              print("total file "+datas.length.toString());
              String path =await localPath();
              try{
                String fileName = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";

                //String fileName = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3";



                // String fileOne = datas[0];
                // String fileTwo = datas[1];
                // String command ="ffmpeg -i $fileOne -i $fileTwo -filter complex amerge $fileName";
                // print(command);
                //
                // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
                // File ff = File(fileName);
                // print(ff.path);
                // //ff.writeAsString('xxx');
                // String pp = ff.path;
                // print(pp);


                // _flutterFFmpeg.execute("-i $fileOne -i $fileTwo -c copy $pp")
                //     .then((return_code) => print("Return code $return_code"));

                // _flutterFFmpeg.execute(command).then((rc) => print("FFmpeg process exited with rc $rc"));
                // print(output);

                await concatenate(
                    datas,output: fileName

                );
                // print(track);
                // print(await track.exists());
                // print("got file "+track.path);

                //file.add(fileName);
                //setState(() {
                //file.add(fileName);
                //fileBool.add({"path":fileName,"selected":false});

                //  });
                _listofFiles();
              }catch(e){
                //  setState(() {


                //  });
                _listofFiles();
                print("concat error");
                print(e);
              }

            }

            fuseAudio(filesSt);
            },child: Container(margin: EdgeInsets.all(15),decoration: BoxDecoration(color: Colors.redAccent,borderRadius: BorderRadius.circular(5)),width: MediaQuery.of(context).size.width,height: 50,child: Center(child: Text("Merge Audio sequentialy"),),)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          if(recording){
            if(await widget.record.isRecording())
              widget.record.stop().then((value) {
                print(value);
                setState(() {
                  recording = !recording;


                });
                Future.delayed(Duration(seconds: 1)).then((value) {
                  _listofFiles();

                });
              });
          }else{
            bool result = await widget.record.hasPermission();
            if(result) {
              String path =await localPath();
              setState(() {
                recording = !recording;


              });
              await widget.record.start(
                path: path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".mp3", // required
                encoder: AudioEncoder.AMR_NB, // by default
                bitRate: 128000, // by default
              );
            }
          }



        },
        tooltip: 'Record',
        child:  Icon(recording?Icons.stop: Icons.mic),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  String file;
  bool selected;
  Function(bool) isSelected;
  AudioPlayerWidget({required this.file,required this.selected,required this.isSelected});
  AudioPlayer advancedPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
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

    return ListTile(onTap: (){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(link: widget.file,)),
      );

    },subtitle: Text(getMinute(durationSecond)),leading: Checkbox(value: widget.selected,onChanged: (val){
      //setState(() {
       widget. selected = val!;
      //});
      widget.isSelected(val!);

    },),title: Text(widget.file.split('/').last),trailing: StreamBuilder<PlayerState>(
        stream: widget. advancedPlayer.onPlayerStateChanged,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            if(snapshot.data == PlayerState.PLAYING){
              return IconButton(onPressed: (){
                widget.advancedPlayer.pause();
              }, icon: Icon(Icons.pause));
            }else if(snapshot.data == PlayerState.COMPLETED){
              widget.advancedPlayer.stop();

                currrentPosition = 0;


              return IconButton(onPressed: (){
                widget.advancedPlayer.play(widget.file);
              }, icon: Icon(Icons.play_arrow));
            }else if(snapshot.data == PlayerState.PAUSED){
              return IconButton(onPressed: (){
                widget.advancedPlayer.resume();
              }, icon: Icon(Icons.play_arrow));
            }else if(snapshot.data == PlayerState.STOPPED){

                currrentPosition = 0;


              return IconButton(onPressed: (){
                widget.advancedPlayer.resume();
              }, icon: Icon(Icons.play_arrow));
            }else{
              return IconButton(onPressed: (){
                widget.advancedPlayer.play(widget.file);
              }, icon: Icon(Icons.play_arrow));
            }

          }else{
            return IconButton(onPressed: (){
              widget.advancedPlayer.play(widget.file);
            }, icon: Icon(Icons.play_arrow));

          }

        }),);
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

class SingleAudioPlayer extends StatefulWidget {
  String link;
  SingleAudioPlayer({required this.link});
  int progress = 0 ;

  bool isReady = false;

  @override
  _SingleAudioPlayerState createState() => _SingleAudioPlayerState();

}

class _SingleAudioPlayerState extends State<SingleAudioPlayer> {
  var progressStream;
  String waveFile = "";
  late Waveform waveform;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    prepareData();
    //initAudio(filePath: widget.file);
  }
  prepareData() async {
    String path =await localPath();
     waveFile = path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+'waveform.wave';
    print(waveFile);

     progressStream = JustWaveform.extract(
      audioInFile: File(widget.link),
      waveOutFile: File(waveFile),
      zoom: const WaveformZoom.pixelsPerSecond(100),
    );
    progressStream.listen((waveformProgress) {
      setState(() {
        widget.progress = (100 * waveformProgress.progress).toInt();
      });
      print('Progress: %${(100 * waveformProgress.progress).toInt()}');
      if (waveformProgress.waveform != null) {

        waveform = waveformProgress.waveform;
        // Use the waveform.
        print("use waveform");
        setState(() {
          widget.isReady = true ;
        });
      }
    });
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
    showImage(){

    return  Container(height: 300,width: MediaQuery.of(context).size.width,
      child: AudioWaveformWidget(
          waveform: waveform,
          start: Duration.zero,
          duration: waveform.duration,
        ),
    );

    }

     Text("ok");


    //ffmpeg -i input -filter_complex "showwavespic=s=640x120" -frames:v 1 output.png
    return SafeArea(child: Scaffold(body: Column(
      children: [
        
        AudioPlayerWidgetButtonOnly(file: widget.link,grap: widget.isReady?showImage():Container(height: 0,width: 0,),),
      ],
    ),));
  }
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
    this.scale = 1.0,
    this.strokeWidth = 1.0,
    this.pixelsPerStep = 1.0,
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

class UserLoggedInStream{
  static UserLoggedInStream model =UserLoggedInStream();
  final StreamController<bool> _Controller = StreamController<bool>.broadcast();

  Stream<bool> get outData => _Controller.stream;

  Sink<bool> get inData => _Controller.sink;

  dataReload(bool v) {
    fetch().then((value) => inData.add(v));
  }

  void dispose() {
    _Controller.close();
  }

  static UserLoggedInStream getInstance() {
    if (model == null) {
      model = new UserLoggedInStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
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
                  }, icon: Icon(Icons.pause));
                }else if(snapshot.data == PlayerState.COMPLETED){
                  widget.advancedPlayer.stop();

                  currrentPosition = 0;


                  return IconButton(onPressed: (){
                    widget.advancedPlayer.play(widget.file);
                  }, icon: Icon(Icons.play_arrow));
                }else if(snapshot.data == PlayerState.PAUSED){
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.resume();
                  }, icon: Icon(Icons.play_arrow));
                }else if(snapshot.data == PlayerState.STOPPED){

                  currrentPosition = 0;


                  return IconButton(onPressed: (){
                    widget.advancedPlayer.resume();
                  }, icon: Icon(Icons.play_arrow));
                }else{
                  return IconButton(onPressed: (){
                    widget.advancedPlayer.play(widget.file);
                  }, icon: Icon(Icons.play_arrow));
                }

              }else{
                return IconButton(onPressed: (){
                  widget.advancedPlayer.play(widget.file);
                }, icon: Icon(Icons.play_arrow));

              }

            }),
        Align(alignment: Alignment.bottomCenter,child: Text(getMinute(durationSecond)),),

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


class AudioPlayerWidgetButtonOnly extends StatefulWidget {
  String file;
  Widget grap;
  AudioPlayerWidgetButtonOnly({required this.file,required this.grap});
  AudioPlayer advancedPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  _AudioPlayerWidgetButtonOnlyState createState() => _AudioPlayerWidgetButtonOnlyState();
}

class _AudioPlayerWidgetButtonOnlyState extends State<AudioPlayerWidgetButtonOnly> {
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
    return   Column(
      children: [
        Container(height: 60,child: Center(child: Text("Playback",style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),)),),
        Container(height: 0.5,color: Colors.black,),
        Container(height: 300,width: MediaQuery.of(context).size.width,child: Stack(
          children: [
            Align(alignment: Alignment.center,child: widget.grap,),
            Align(alignment: Alignment.center,child: Opacity(opacity: 0.3,
              child: StreamBuilder<Duration>(
                  stream:  widget.advancedPlayer.onAudioPositionChanged,
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      if(snapshot.data == durationSecond)return   LinearProgressIndicator(minHeight: 300,color: Colors.blue.withOpacity(0.5),value: 0,);
                      else  return LinearProgressIndicator(minHeight: 300,color: Colors.blue.withOpacity(0.5),value: snapshot.data!.inMilliseconds/(durationSecond*1000),);
                      return Text(snapshot.data!.inSeconds.toString());

                    }else{
                      return Container(height: 0,width: 0,);
                    }

                  }),
            ) ,),
          ],
        ),),
        Container(width: MediaQuery.of(context).size.width,height: 60,
          child: Center(
            child: Row(
              children: [
                Container(width: 60,height: 60,child: Center(child: StreamBuilder<PlayerState>(
                    stream: widget. advancedPlayer.onPlayerStateChanged,
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        if(snapshot.data == PlayerState.PLAYING){
                          return IconButton(onPressed: (){
                            widget.advancedPlayer.pause();
                          }, icon: Icon(Icons.pause));
                        }else if(snapshot.data == PlayerState.COMPLETED){
                          widget.advancedPlayer.stop();

                          currrentPosition = 0;


                          return IconButton(onPressed: (){
                            widget.advancedPlayer.play(widget.file);
                          }, icon: Icon(Icons.play_arrow));
                        }else if(snapshot.data == PlayerState.PAUSED){
                          return IconButton(onPressed: (){
                            widget.advancedPlayer.resume();
                          }, icon: Icon(Icons.play_arrow));
                        }else if(snapshot.data == PlayerState.STOPPED){

                          currrentPosition = 0;


                          return IconButton(onPressed: (){
                            widget.advancedPlayer.resume();
                          }, icon: Icon(Icons.play_arrow));
                        }else{
                          return IconButton(onPressed: (){
                            widget.advancedPlayer.play(widget.file);
                          }, icon: Icon(Icons.play_arrow));
                        }

                      }else{
                        return IconButton(onPressed: (){
                          widget.advancedPlayer.play(widget.file);
                        }, icon: Icon(Icons.play_arrow));

                      }

                    }),),),
                Column(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.file.split('/').last),
                    Text(getMinute(durationSecond)),
                  ],
                )


                // StreamBuilder<Duration>(
                // stream:  widget.advancedPlayer.onAudioPositionChanged,
                // builder: (context, snapshot) {
                // if(snapshot.hasData){
                //   return Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Slider(min: 0.0,
                //       max: 100.0,value: (100*snapshot.data!.inSeconds)/durationSecond,onChanged: (val){
                //         setState(() {
                //           currrentPosition =( (val*durationSecond) as int)*100;
                //         });
                //
                //       },),
                //   );
                //   return Text(snapshot.data!.inSeconds.toString());
                //
                // }else{
                //   return Text("Wait");
                // }
                //
                // }),


              ],
            ),
          ),
        ),
      ],
    );


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