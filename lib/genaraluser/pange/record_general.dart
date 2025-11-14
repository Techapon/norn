
// import 'dart:async';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/recording.dart';

class RecordGeneral extends StatefulWidget {
  const RecordGeneral({super.key});

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

  void reset() {
    runtime.resetTimer(() => setState(() {}));
  }

  // TimeOfDay selectefTime = TimeOfDay.now();

  late Timer timer;
  DateTime now = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Show
        Container(
          padding: EdgeInsets.all(60),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black12,
              width: 1.5
            )
          ),

          child: Text(runtime.getTimeFormatted(),style: TextStyle(fontSize: 30),),
        ),

        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Start
            ElevatedButton(
              onPressed: (){
                start();
              },
              child: Text("start")
            ),

            SizedBox(width: 20),

            // Stop
            ElevatedButton(
              onPressed: (){
                stop();
              },
              child: Text("stop")
            ),

            SizedBox(width: 20),
            
            // Reset
            ElevatedButton(
              onPressed: (){
                reset();
              },
              child: Text("reset")
            )
          ],
        )
      ],
    );
  }
}