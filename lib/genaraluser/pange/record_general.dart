import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/recording.dart';

import 'package:permission_handler/permission_handler.dart';

class RecordGeneral extends StatefulWidget {
  const RecordGeneral({super.key});

  @override
  State<RecordGeneral> createState() => _RecordGeneralState();
}

class _RecordGeneralState extends State<RecordGeneral> {

  Runtime runtime = Runtime();

  @override
  void initState() {
    super.initState();
    onSaveSuccess = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  void dispose() {
    onSaveSuccess = null;
    super.dispose();
  }

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
              onPressed: () async{
                bool granted = await requestMicrophonePermission();
                if (!granted) {
                  print("ไม่สามารถอัดเสียงได้เพราะไม่มี permission");
                  return;
                }
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
        
          ],
        ),

        Text("alram test"),

        FilledButton(
          onPressed: () {
            if (isAlarmPlaying) return;
            playAlarm();
          },
          child: Text("play Alram")
        ),
        FilledButton(
          onPressed: () {
            stopAlarm();
          },
          child: Text("stop Alram")
        )
      ],
    );
}

  // 🎯 เล่นเสียงปลุก (ใช้ไฟล์ an.wav)
  Future<void> playAlarm() async {
    try {
      setState(() {
        isAlarmPlaying = true;
      });
      
      // ใช้ไฟล์เสียง an.wav
      await _audioPlayer.play(AssetSource('soundassets/alarm_01.wav'), 
        volume: 1.0,
      );
      
      // วนเล่นซ้ำ
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      
    } catch (e) {
      print('Error playing alarm: $e');
      // แสดง error ให้ผู้ใช้ทราบ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่พบไฟล์เสียง alarm_01.wav'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // 🎯 หยุดเสียงปลุก
  Future<void> stopAlarm() async {
    if (isAlarmPlaying) {
      await _audioPlayer.stop();
      setState(() {
        isAlarmPlaying = false;
      });
    }
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