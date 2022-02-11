import 'package:audio/utils/appConst.dart';
import 'package:audio/utils/textStyleConst.dart';
import 'package:audio/utils/themeManager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetElements{
  Widget AudioPlayer001({required String link}){
    return AudioPlayerWidgetLiveAudio(file:link,);


  }
  Widget bigButton({required String label}){
    return Container(
        alignment: Alignment.center,
        height: height * 0.058,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height*0.008),
          color: ThemeManager().getDarkGreenColor,
        ),
        child: Text(
          label,
          style: interSemiBold.copyWith(
              fontSize: width*0.04, color: ThemeManager().getWhiteColor),
        ));

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
       if(mounted) setState(() =>  durationSecond = d.inSeconds);
      });


      widget.advancedPlayer.onAudioPositionChanged.listen((Duration  p) => {

        if(mounted)  setState(() => currrentPosition = p.inSeconds)
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