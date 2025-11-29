import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/limulator/machine.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/limulator/ai.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/checkapnea.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/storevoice.dart';
import 'package:nornsabai/genaraluser/general_main.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/record/uploadingses.dart';
import 'package:nornsabai/model/data_model/shortVoiceModel.dart';

<<<<<<< HEAD
int totoalseconds = 0;
int id = 0;
Function? onSaveSuccess;

=======
int id = 0;
>>>>>>> 2461ab2 (discover 1 + large ui -- v1)
class Runtime {
  late Timer timer; 
  bool isRunning = false;

  // id
<<<<<<< HEAD
=======
  
>>>>>>> 2461ab2 (discover 1 + large ui -- v1)

  late DateTime now;

  // start & end
  late DateTime startsession;
  late DateTime endsession;

  // Start Timer
  void startTimer(void Function() ontick) async{
    if (isRunning) return;

    now = DateTime.now();
    startsession = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second
    );

    isRunning = true;

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      totoalseconds++;
      ontick();
    });

    // update breath status
    updatebreath.updateBreathingT();

    recordVoiceMachince(() => isRunning, (filepath,voiceValue,startAt,endAT,ended) {
      
      if (!ended) {
        
        id++;

        print(filepath);

        // // craeate class for short voice
        Shortvoicemodel shortvoice = Shortvoicemodel(
          id: id,
          filePath: filepath,
          shortValue: voiceValue,
          ended: ended,
          shortstart: startAt,
          shortend: endAT
        );

        print("Input voice ${id}");
        AiAnalyzeSound(shortvoice);
        
      }else {
        sessionTemStore["startTime"] = Timestamp.fromDate(startAt);
        sessionTemStore["endTime"] = Timestamp.fromDate(endAT);
        
        id++;
        
        // // craeate class for to br signend voice
        Shortvoicemodel shortvoice = Shortvoicemodel(
          id: id, // Use current id, don't increment
          filePath: filepath,
          shortValue: voiceValue,
          ended: ended,
          shortstart: startAt,
          shortend: endAT
        );

        print("Endddd voice ${id}");

        AiAnalyzeSound(shortvoice);
<<<<<<< HEAD

        totoalseconds = 0;
        id = 0;
        
        timer.cancel();
        ontick();

=======
    
>>>>>>> 2461ab2 (discover 1 + large ui -- v1)
      }
    });
  }

  // Stop function
  void stopTimer(void Function() ontick) {
    if (!isRunning) return;
<<<<<<< HEAD
=======
    uploading = true;

    // update breath status
    updatebreath.updateBreathingNll();

    totoalseconds = 0;
    
    alerted = false;

>>>>>>> 2461ab2 (discover 1 + large ui -- v1)
    isRunning = false;

  }


  // Get time
  String getTimeFormatted() {
    int hours = totoalseconds ~/ 3600;
    int minutes = (totoalseconds % 3600) ~/ 60;
    int seconds = totoalseconds % 60;
    
    String twoDigits(int value) => value.toString().padLeft(2,"0");

    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  }


}