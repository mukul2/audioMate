import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
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
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF36004C)
  ));
  runApp(const MyApp());
}
double appbarHeight = 0;
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF36004C),appBarTheme: AppBarTheme(elevation: 1,
        backgroundColor: Color(0xFF36004C),
      ),
        textTheme:Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ) ,
        inputDecorationTheme: InputDecorationTheme(hintStyle: TextStyle(color: Colors.white),border: OutlineInputBorder(borderSide:BorderSide(color: Colors.white,width: 0.0 ) ),enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.white, width: 0.0),
        ),),



        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.white,
        accentColor: Colors.white
      ),
      home:Container(color: Colors.white,child: SafeArea(child: Scaffold(body: StreamBuilder(
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

                    return true?AllProjectsHome():MyHomePage();

                  }
                  return Scaffold(body: Center(child: Text("Please wait"),),);


                }
              //Auth stream
            );
          }),)),),
    );
  }
}

class AllProjectsHome extends StatefulWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
   AllProjectsHome({Key? key}) : super(key: key);

  @override
  _AllProjectsHomeState createState() => _AllProjectsHomeState();
}

class _AllProjectsHomeState extends State<AllProjectsHome> {
  double width = 0;
  @override
  Widget build(BuildContext context) {
    width =  MediaQuery.of(context).size.width;
    return Container(color: Colors.white,
      child: SafeArea(child: Scaffold(appBar: AppBar(
        title: Text("Projects"),actions: [

        IconButton(onPressed: (){


          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SoundUpload()),
          );

        }, icon:Icon(Icons.upload)),
        IconButton(onPressed: (){


          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateNewProject()),
          );

        }, icon:Icon(Icons.add)),
        Container(margin: EdgeInsets.only(right: 15),child: CircleAvatar(backgroundColor: Colors.white,)),
      ],
      ),body:StreamBuilder<QuerySnapshot>(
          stream:widget.firestore.collection("projects").where("uid",isEqualTo: widget.auth.currentUser!.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.hasData){
              return  ListView.builder(shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(onTap: (){
                      //Oneproject


                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Oneproject(queryDocumentSnapshot: snapshot.data!.docs[index],)),
                      );

                    },
                      child: Container(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text( snapshot.data!.docs[index].get("title"),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            ),
                            Container(height: 0.1,width: width,color: Colors.white,),

                          ],

                        ),
                      ),
                    );
                  });
            }else{
              return Scaffold(body: Center(child: Text("No Projects"),),);
            }

          }),)),
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
      length: 3,
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
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyProjects()),
            );
          }, icon: Icon(Icons.work)),

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
              Tab(icon: Icon(Icons.work,),text: "Projects",),
              Tab(icon: Icon(Icons.save),text: "Saved sounds",),
              Tab(icon: Icon(Icons.cloud),text: "More Clips",),
            ],
          ),
        ),
        body:   TabBarView(
          children: [
            MyProjects(),
            Column(
              children: [

                Expanded(
                  child: ListView.builder(shrinkWrap: true,
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
                ),
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

                     // Navigator.push(
                     //   context,
                     //   MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(link: file.path,width: MediaQuery.of(context).size.width,)),
                     // );


                   },leading: AudioPlayerWidgetLiveAudio(file: snapshot.data!.docs[index].get("link"),),trailing: IconButton(icon: Icon(Icons.download),onPressed: () async {
                     var url = Uri.parse(snapshot.data!.docs[index].get("link"));


                     Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
                     String appDocumentsPath = appDocumentsDirectory.path; // 2
                     String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName");

                     if(await File(filePath).exists()){

                     }else{
                       var response = await http.get(url);

                       File file = File(filePath);
                       await file.writeAsBytes(response.bodyBytes);
                     }


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
class MyProjects extends StatefulWidget {
  const MyProjects({Key? key}) : super(key: key);

  @override
  _MyProjectsState createState() => _MyProjectsState();
}

class _MyProjectsState extends State<MyProjects> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white,child: SafeArea(
      child:Scaffold(floatingActionButton: FloatingActionButton.extended(onPressed: (){
         Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateNewProject()),
            );


      }, label: Text("Create Project"),icon: Icon(Icons.add),),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
        children: [
          


    ],
    ),
      ),
    )
    ),);
  }
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
              child: TextFormField(controller: controller,

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
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(link: widget.file,width: MediaQuery.of(context).size.width)),
      // );

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
  String wave;
  double width;
  SingleAudioPlayer({required this.wave,required this.link,required this.width});
  AudioPlayer advancedPlayer = AudioPlayer();
  bool isPlaying = false;
  int progress = 0 ;

  bool isReady = false;

  double currrentPositionLeftOffset =20;

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
    playerStateManagement();

    //initAudio(filePath: widget.file);
  }
  void playerStateManagement() {
    widget.width =  widget.width-40;
    print("width "+widget.width.toString());

    widget.advancedPlayer.setUrl(widget.link).then((value) {


      widget.advancedPlayer.onDurationChanged.listen((Duration d) {
        print('Max duration: $d');
        if(mounted) setState(() { durationMillis = d.inMilliseconds;});
      });


      widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {

        if(mounted) setState(() {
          currrentPosition = p.inSeconds;
          int  currentPosInMillis = p.inMilliseconds;

          widget.currrentPositionLeftOffset =20+(widget.width)*(((((currentPosInMillis)*1))/(durationMillis)));
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

    waveform = await JustWaveform.parse(File(widget.wave));
    setState(() {
      widget.isReady = true ;
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
    double width = MediaQuery.of(context).size.width;
    showImage(){

    return  Container(height: 90,width: MediaQuery.of(context).size.width,
      child: AudioWaveformWidget(
          waveform: waveform,
          start: Duration.zero,
          duration: waveform.duration,
        ),
    );

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
     Text("ok");
    return WillPopScope (
      onWillPop: () async {
    return true;
    },
      child:SafeArea(child: Scaffold(appBar: AppBar(),body: Stack(
        children: [
          Align(alignment: Alignment.center,child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10,),),
            margin: EdgeInsets.all(0),height: 125,
        child: Stack(children: [
          Align(alignment: Alignment.center,child:widget.isReady?Container(margin: EdgeInsets.only(top: 0,left: 20,right: 20),child: showImage(),):Container(child:Center(child: CircularProgressIndicator())  ,) ,),


          Align(alignment: Alignment.center,child: Opacity(opacity: 0.3,
            child: Container(margin: EdgeInsets.only(top: 0,left: 20,right: 20),
              child: StreamBuilder<Duration>(
                  stream:  widget.advancedPlayer.onAudioPositionChanged,
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      if(snapshot.data == durationMillis)return   Container(

                        width: width,
                        height: 125,
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
                        height: 125,
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
                        height: 125,
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
          Align(alignment: Alignment.center,child: Container(margin: EdgeInsets.only(bottom: 35),height: 160,
            child: Stack(
              children: [
                Positioned(left:widget.currrentPositionLeftOffset-25,child: Container(width: 50,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: Text(getMinute(currrentPosition))),
                      CircleAvatar(radius: 7,backgroundColor: Colors.white,),
                      Container(  height: 170,width: 4,color: Colors.white,)
                    ],
                  ),
                ),),
              ],
            ),
          ),),

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
    showImage(){

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

    Text("ok");

    return widget.isReady?Container(margin: EdgeInsets.only(top: 2,left: 2,right: 2,bottom: 2),child: Container(decoration: BoxDecoration(color: Colors.redAccent,borderRadius: BorderRadius.circular(5)
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
    this.waveColor = Colors.white,
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
class MaxDurationFounndStream{
  static MaxDurationFounndStream model =MaxDurationFounndStream();
  final StreamController<bool> _Controller = StreamController<bool>.broadcast();

  Stream<bool> get outData => _Controller.stream;

  Sink<bool> get inData => _Controller.sink;

  dataReload(bool v) {
    fetch().then((value) => inData.add(v));
  }

  void dispose() {
    _Controller.close();
  }

  static MaxDurationFounndStream getInstance() {
    if (model == null) {
      model = new MaxDurationFounndStream();
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


class AudioPlayerWidgetButtonOnly extends StatefulWidget {
  String file;
  AudioPlayerWidgetButtonOnly({required this.file,});
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
  void dispose() {

    widget. advancedPlayer.stop();
    widget.advancedPlayer.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playerStateManagement();
    //widget. advancedPlayer
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
    return   Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(height: 100,width: MediaQuery.of(context).size.width,child: Stack(
          children: [
            //Align(alignment: Alignment.center,child: widget.grap,),
            Align(alignment: Alignment.center,child: Opacity(opacity: 0.3,
              child: StreamBuilder<Duration>(
                  stream:  widget.advancedPlayer.onAudioPositionChanged,
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      if(snapshot.data == durationSecond)return   LinearProgressIndicator(minHeight: 100,color: Colors.blue.withOpacity(0.5),value: 0,);
                      else  return LinearProgressIndicator(minHeight: 100,color: Colors.blue.withOpacity(0.5),value: snapshot.data!.inMilliseconds/(durationSecond*1000),);
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
       if(mounted) setState(() =>  durationSecond = d.inSeconds);
      });


      widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {

        if(mounted) setState(() => currrentPosition = p.inSeconds)
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


class Oneproject extends StatefulWidget {
  QueryDocumentSnapshot queryDocumentSnapshot ;
  Oneproject({required this.queryDocumentSnapshot});
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String currentrecordingFilePath = "";
  bool isProcessing = false;


  @override
  _OneprojectState createState() => _OneprojectState();
}

class _OneprojectState extends State<Oneproject> {
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

    StreamBuilder(
    stream: allAudioOnly[maxMusicIndex].onPlayerStateChanged,
    builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {}),
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
                showModalBottomSheet(isScrollControlled: true,
                context: context,
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
                              stream: widget.firestore.collection("loops").snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if(snapshot.hasData){
                                  return ListView.builder(shrinkWrap: true,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return InkWell(onTap: () async {

                                          // var url = Uri.parse(snapshot.data!.docs[index].get("wave"));
                                          // var response = await http.get(url);
                                          // Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
                                          // String appDocumentsPath = appDocumentsDirectory.path; // 2
                                          // String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName").toString().replaceAll("mp3", "wave");
                                          // File fileWave = File(filePath);
                                          // await fileWave.writeAsBytes(response.bodyBytes);

                                          widget.firestore
                                              .collection("projects")
                                              .doc(widget.queryDocumentSnapshot.id).collection("tracks").add({"time":DateTime.now().millisecondsSinceEpoch,"file":snapshot.data!.docs[index].get("file"),"wave":snapshot.data!.docs[index].get("wave"),"email":widget.auth.currentUser!.email,"fileName":snapshot.data!.docs[index].get("file").split('/').last,"uid":widget.auth.currentUser!.uid});




                                          Navigator.pop(context);
                                        },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(0.0),
                                                child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    AudioPlayerWidgetLiveAudio(file: snapshot.data!.docs[index].get("file"),),
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
                  return Container(height: MediaQuery.of(context).size.height*0.8,
                   width: MediaQuery.of(context).size.width,child: Column(
                      children: [

                      ],
                    ),
                  );
                });



                },icon: Icon(Icons.music_note,color: Colors.white, ),),
              ),
            ),
          ),
          Card(elevation: 5,color: Colors.redAccent,shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27.5),
          ),
            child: Container(height: 55,width: 55,
              child: Center(
                child: MicForProject(projectId: widget.queryDocumentSnapshot.id,),
              ),
            ),
          ),
        ],),)),
        Align(alignment: Alignment.center,child: FutureBuilder<QuerySnapshot>(
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
                      MaxDurationFounndStream.getInstance().dataReload(true);

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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(wave: snapshotW.data!,link:  snapshot.data!.docs[j].get("file"),width: MediaQuery.of(context).size.width)),
                                    );
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





                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        Future<String> downloadFile({required String link})async{
                          var url = Uri.parse(snapshot.data!.docs[index].get("wave"));
                          var response = await http.get(url);
                          Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
                          String appDocumentsPath = appDocumentsDirectory.path; // 2
                          String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName").toString().replaceAll("mp3", "wave");
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
                          return dd.inMilliseconds;
                          return  await advancedPlayer.getDuration();
                          // return d.inMilliseconds;



                        }
                        return  FutureBuilder<String>(
                          future: downloadFile(link: snapshot.data!.docs[index].get("file")), // async work
                          builder: (BuildContext context, AsyncSnapshot<String> snapshotW) {
                            switch (snapshotW.connectionState) {
                              case ConnectionState.done:
                                return InkWell(onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(wave: snapshotW.data!,link:  snapshot.data!.docs[index].get("file"),width: MediaQuery.of(context).size.width)),
                                  );
                                },child: FutureBuilder<int>(
                                  future: getMusicLenght(link: snapshot.data!.docs[index].get("file")), // async work
                                  builder: (BuildContext context, AsyncSnapshot<int> snapshotD) {
                                    if(snapshotD.hasData){
                                      return Row(
                                        children: [
                                          Text((snapshotD.data!).toString()),
                                          Container(width: MediaQuery.of(context).size.width-60 , child: SingleAudioGraph(wi: 10,link: snapshotW.data!,)),

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
                        );

                        return SingleAudioGraph(wi: 10,link: "",);
                        return   ListTile(onTap: () async {


                          var url = Uri.parse(snapshot.data!.docs[index].get("file"));
                          var response = await http.get(url);
                          Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
                          String appDocumentsPath = appDocumentsDirectory.path; // 2
                          String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName");
                          File file = File(filePath);
                          await file.writeAsBytes(response.bodyBytes);


                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) =>  SingleAudioPlayer(link: file.path,width: MediaQuery.of(context).size.width)),
                          // );


                        },leading: AudioPlayerWidgetLiveAudio(file: snapshot.data!.docs[index].get("file"),),trailing: IconButton(icon: Icon(Icons.download),onPressed: () async {
                          var url = Uri.parse(snapshot.data!.docs[index].get("file"));
                          var response = await http.get(url);
                          Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
                          String appDocumentsPath = appDocumentsDirectory.path; // 2
                          String filePath = '$appDocumentsPath/'+snapshot.data!.docs[index].get("fileName");
                          File file = File(filePath);
                          await file.writeAsBytes(response.bodyBytes);



                        },),subtitle: Text(snapshot.data!.docs[index].get("email")),title: Text( snapshot.data!.docs[index].get("fileName")),);

                      }),
                );

              }else{
                return Center(child: Text("No Tracks"),);
              }

            }),)
      ],
    ),));
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
    return Container(child: SafeArea(
      child: Scaffold(appBar: AppBar(title: Text("Upload track"),),
        body: Column(
          children: [
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
                                .collection("loops").add({"type":"guiter","time":DateTime.now().millisecondsSinceEpoch,"file":value,"wave":valueWaveFile,"email":widget.auth.currentUser!.email,"fileName":file.path.split('/').last,"uid":widget.auth.currentUser!.uid});
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
              child: Container(margin: EdgeInsets.all(8.0),decoration: BoxDecoration(color: Colors.deepPurpleAccent),child: Center(child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Guiter",style: TextStyle(color: Colors.white),),
              ),),),
            ),
          ],
        ),
      ),
    ),);
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