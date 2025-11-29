import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/Mybutton_log_and_sigup.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/recording.dart';
import 'package:nornsabai/Myfunction/globalFunc/alarmsystem/screen/alarm_ge.dart';
import 'package:nornsabai/genaraluser/general_main.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/record/func/latestsession.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/record/page/sleep.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/record/widget/container.dart';
import 'package:nornsabai/genaraluser/pange/result_ganeral.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordGeneral extends StatefulWidget {
  const RecordGeneral({super.key,required this.latestSessionData,required this.setcurrent});

  final LatestSessionData? latestSessionData;
  final void Function(int)? setcurrent;

  @override
  State<RecordGeneral> createState() => _RecordGeneralState();
}

class _RecordGeneralState extends State<RecordGeneral> {

  Runtime runtime = Runtime();

  void start() {
    runtime.startTimer(() => setState(() {}));
  }

  void stop() {
    runtime.stopTimer(() => setState(() {}));
  }

  // TimeOfDay selectefTime = TimeOfDay.now();

  late Timer timer;
  DateTime now = DateTime.now();

  bool isAlarmPlaying = false;
  final _audioPlayer = AudioPlayer();
  
  @override
  Widget build(BuildContext context) {
    List<Color> textandbg = [Color.fromARGB(255, 84, 141, 172),Color.fromARGB(255, 138, 190, 218)];

    LatestSessionData? sleepLastses = widget.latestSessionData;

    String sleepsubtitle;
    if (sleepLastses?.formattedDuration == null) {
      sleepsubtitle = "";
    }else {
      sleepsubtitle = "${sleepLastses?.formattedDuration} hours";
    }

    String resultsubtitle;
    if (sleepLastses?.id == null) {
      resultsubtitle = "";
    }else {
      resultsubtitle = "${sleepLastses?.id} sessions";
    }

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
      
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 35),
                child: Image.asset("image/nornsabai_logo.png",width: 225,),
              ),
            ],
          ),


          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 30),
            child: Column(
              children: [
                // row
                Row(
                  children: [
                    RecordContainer(
                      size: 150,
                      icon: Icons.king_bed,
                      title: "Sleep Duration",
                      subtitle: sleepsubtitle,
                      onTap: () {
                        
                      },
                    ),
            
                    SizedBox(width: 20,),
            
                    RecordContainer(
                      size: 137.5,
                      icon: Icons.play_circle_fill,
                      title: "Result",
                      subtitle: resultsubtitle,
                      onTap: () {
                        widget.setcurrent?.call(1);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20,),

                Row(
                  children: [
                    RecordContainer(
                      size: 145,
                      icon: Icons.health_and_safety,
                      title: "Treatment",
                      subtitle: "",
                      onTap: () {
                        
                      },
                    ),

                    SizedBox(width: 20,),
            
                    RecordContainer(
                      size: 145,
                      icon: Icons.coffee,
                      title: "Factor",
                      subtitle: "",
                      onTap: () {
                        
                      },
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 87, 141, 203),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                      onPressed: () async {
                        bool granted = await requestMicrophonePermission();
                        if (!granted) {
                          print("ไม่สามารถอัดเสียงได้เพราะไม่มี permission");
                          return;
                        }else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Sleeping()));
                        }
                      },
                      child: Text("Start",style: TextStyle(color: Colors.white,fontSize: 30),)
                    ),
                  ),
                ),
              
              ],
            ),
          )
        ],
      ),
    );
}

  // permission function
  Future<bool> requestMicrophonePermission() async {
    // ตรวจสอบสถานะ permission
    var status = await Permission.microphone.status;
    
    if (status.isGranted) {
      return true;
    } else {
      // ขออนุญาต
      status = await Permission.microphone.request();
      return status.isGranted;
    }
  }

}




// Container(
//   padding: EdgeInsets.all(60),
//   decoration: BoxDecoration(
//     shape: BoxShape.circle,
//     border: Border.all(
//       color: Colors.black12,
//       width: 1.5
//     )
//   ),

//   child: Text(runtime.getTimeFormatted(),style: TextStyle(fontSize: 30),),
// ),


// Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [

//     // Start
    // ElevatedButton(
    //   onPressed: () async{
    //     bool granted = await requestMicrophonePermission();
    //     if (!granted) {
    //       print("ไม่สามารถอัดเสียงได้เพราะไม่มี permission");
    //       return;
    //     }
    //     start();
    //   },
    //   child: Text("start")
    // ),

//     SizedBox(width: 20),

//     // Stop
//     ElevatedButton(
//       onPressed: (){
//         stop();
//       },
//       child: Text("stop")
//     ),

//     SizedBox(width: 20),

//   ],
// ),

// SizedBox(height: 10,),
// Text("alram test"),

// FilledButton(
//   onPressed: () {
//     AlarmApnea();
//   },
//   child: Text("play Alram")
// ),

// // --------------------
// SizedBox(height: 10,),
// Text("Calling test"),

// FilledButton(
//   onPressed: () {
//     // update breath status
//     updatebreath.updateBreathingT();
//   },
//   child: Text("set to ture")
// ),

// FilledButton(
//   onPressed: () {
//     // update breath status
//     updatebreath.updateBreathingF();
//   },
//   child: Text("set to false")
// ),

// FilledButton(
//   onPressed: () {
//     // update breath status
//     updatebreath.updateBreathingNll();
//   },
//   child: Text("set to null")
// // ),
  //   var status = await Permission.microphone.status;
    
  //   if (status.isGranted) {
  //     return true;
  //   } else {
  //     // ขออนุญาต
  //     status = await Permission.microphone.request();
  //     return status.isGranted;
  //   }
  // }

// }
//   onPressed: () {
//     // update breath status
//     updatebreath.updateBreathingF();
//   },
//   child: Text("set to false")
// ),

// FilledButton(
//   onPressed: () {
//     // update breath status
//     updatebreath.updateBreathingNll();
//   },
//   child: Text("set to null")
// ),