import 'package:audio/Home/bLoc/Streams.dart';
import 'package:audio/utils/appConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



import 'package:audio/Home/bLoc/events.dart';
import 'package:audio/Home/bLoc/Streams.dart';
import 'package:audio/Home/bLoc/bloc.dart';
class HomeUI{
  HomeUI();
  Screen(){

    return AllProjectsHome();
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
          HomeScreenEventStream().homeScreenEventsStream.broadCast(homeScreenEvents.uploadAudio);



        }, icon:Icon(Icons.upload)),
        IconButton(onPressed: (){

          HomeScreenEventStream().homeScreenEventsStream.broadCast(homeScreenEvents.createProject);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => CreateNewProject()),
          // );

        }, icon:Icon(Icons.add)),
        IconButton(onPressed: (){

          HomeScreenEventStream().homeScreenEventsStream.broadCast(homeScreenEvents.logoutClicked);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => CreateNewProject()),
          // );

        }, icon:Icon(Icons.logout)),
        Container(margin: EdgeInsets.only(right: 15),child: CircleAvatar(backgroundColor: Colors.white,)),
      ],
      ),body:StreamBuilder<QuerySnapshot>(
          stream:widget.firestore.collection("projects").where("uid",isEqualTo: widget.auth.currentUser!.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

            if(snapshot.hasData){
              return  ListView.separated(shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) => const Divider(),

                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(onTap: (){
                      currentProjectId = snapshot.data!.docs[index].id;
                      HomeScreenEventStream().homeScreenProjectClickedStream.broadCast(snapshot.data!.docs[index]);



                      //Oneproject

                      //
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => Oneproject(queryDocumentSnapshot: snapshot.data!.docs[index],)),
                      // );

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