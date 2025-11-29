import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/recording.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/record/uploadingses.dart';

class Sleeping extends StatefulWidget {
  const Sleeping({super.key});

  @override
  State<Sleeping> createState() => _SleepingState();
}

class _SleepingState extends State<Sleeping> {

  Runtime runtime = Runtime();

  void start() {
    runtime.startTimer(() => setState(() {}));
  }

  void stop() {
    runtime.stopTimer(() => setState(() {}));
  }

  late Timer timer;
  DateTime now = DateTime.now();

  bool isAlarmPlaying = false;
  final _audioPlayer = AudioPlayer();

  
  initState() {
    super.initState();
    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00111D),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("image/recordingBg.jpg"),
            opacity: 0.44,
            fit: BoxFit.cover,
          ),
        ),
        child: WillPopScope(
          onWillPop:  () async => false,
          child: SafeArea(
            child: Stack(
              // alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 35),
                          child: Image.asset("image/nornsabai_logo.png",width: 225,),
                        ),
                      ],
                    ),
                                        
                    //  show time
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF00244D).withOpacity(0.68),
                              Color(0xFF00142B).withOpacity(0.68),
                            ],
                          ),
                        ),
                        padding: EdgeInsets.all(120),
                        child: Column(
                          children: [
                            // time
                            Text(
                              runtime.getTimeFormatted(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 60,
                              ),
                            ),
                      
                            // good night
                            Text("Good Night",style : TextStyle(color: Colors.white,fontSize: 70,fontWeight: FontWeight.bold)),
                      
                            Text(DateFormat('h:mm a').format(DateTime.now()),style : TextStyle(color: Colors.white,fontSize: 35))
                      
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // slide up for pop widget
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Dismissible(
                        
                          key: Key('Slide to Stop'),
                          direction: DismissDirection.up,
                        
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        
                        
                          secondaryBackground: Container(
                            // height: MediaQuery.of(context).size.height * 0.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF00121F),
                                ],
                                stops: [0.0,0.9],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                                        
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 100),
                                      child: Icon(Icons.sunny,color: Colors.white.withOpacity(0.59),size: 200,),
                                    )
                                  ],
                                ),
                                        
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 200),
                                      child: Icon(Icons.bed_outlined,color: Colors.white.withOpacity(0.59),size: 350,),
                                    )
                                  ],
                                ),
                                
                              ],
                            ),
                          ),
                        
                          confirmDismiss: (direction) async {
                            stop();
                            
                            // Show loading dialog while uploading
                            MyDiaologAlertLoad(
                              context: context,
                              desscrip: "Please wait..",
                              pop: false
                            );

                            // Wait for upload to complete by polling the uploading variable
                            while (uploading) {
                              await Future.delayed(Duration(milliseconds: 100));
                            }

                            
                            // Close loading dialog
                            Navigator.pop(context);
                            
                            // Show result dialog
                            MyDiaologAlertSuccess(
                              context: context,
                              whenSuccess: "Data saved successfully!!",
                              // pop: false,
                            );
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                            return false; // Prevent actual dismissal since we're navigating away
                          },
                        
                          child: Container(
                            // margin: EdgeInsets.only(top: MediaQuery.of(context).size.height *0.5),
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 250),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 70,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Slide to Stop",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ]
            )
          ),
        ),
      )
    );
  }
}
