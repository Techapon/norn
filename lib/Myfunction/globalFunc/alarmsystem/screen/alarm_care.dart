import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/genaraluser/general_main.dart';
import 'package:nornsabai/globals.dart';
import 'package:stroke_text/stroke_text.dart';


void AlarmInCare({required String username,required String email}) {
  if (navigatorKey.currentContext != null) {
    Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(builder: (context) => AlarmApnea(username: username,email: email)));
  }
}


class AlarmApnea extends StatefulWidget {
  const AlarmApnea({super.key, required this.username, required this.email});

  final String username;
  final String email;

  @override
  State<AlarmApnea> createState() => _AlarmApneaState();
}

class _AlarmApneaState extends State<AlarmApnea> with SingleTickerProviderStateMixin {

  bool isAlarmPlaying = false;
  final _audioPlayer = AudioPlayer();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    playAlarm();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(  
          color: const Color.fromARGB(255, 238, 62, 49),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StrokeText(
                  text: "${widget.username[0].toUpperCase() + widget.username.substring(1)}",
                  textStyle: GoogleFonts.itim(fontSize: 50,fontWeight: FontWeight.bold,color: Colors.red),
                  textAlign: TextAlign.center,
                  strokeColor: Colors.white,
                  strokeWidth: 5,
                ),

                Text(
                  "is not breathing!!",
                  style: GoogleFonts.itim(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]
            ),
      
            // stop alarm
            Padding(
              padding: EdgeInsets.only(bottom: 135.0,top: 60.0),
              child: Center(
                child: CustomPaint(
                  painter: WavePainter(_controller),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.red, const Color.fromARGB(255, 255, 100, 89)],
                        stops: [0.7,1.0],
                      ),
              
                      border: Border.all(
                        color: Colors.redAccent,
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          stopAlarm(); 
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(100),
                          child: Column(
                            children: [
                              StrokeText(
                                text: "Ignore",
                                textStyle: GoogleFonts.itim(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                                textAlign: TextAlign.center,
                                strokeColor: Colors.white,
                                strokeWidth: 5,
                              ),
                              SizedBox(height: 10,),
                              Text(
                                "and stop Alarm",
                                style: GoogleFonts.itim(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                            ],
                          )
                        ),
                      ),
                    ),
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }




    Future<void> playAlarm() async {
    try {
      setState(() {
        isAlarmPlaying = true;
      });
      
      // ใช้ไฟล์เสียง an.wav
      await _audioPlayer.play(AssetSource('soundassets/an.wav'), 
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
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;

  WavePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    for (int i = 0; i < 3; i++) {
      final progress = (animation.value + (i * 0.33)) % 1.0;
      final currentRadius = radius + (radius * 0.5 * progress);
      final opacity = (1.0 - progress) * 0.4;

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => oldDelegate.animation != animation;
}