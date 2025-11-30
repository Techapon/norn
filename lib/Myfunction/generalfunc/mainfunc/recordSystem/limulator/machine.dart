import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

final List<Uint8List> buffer = [];

Future<void> recordVoiceMachince(
  bool Function() timeRunning,
  void Function(String filePath,double voicevalue , DateTime voiceStart, DateTime voiceEnd, bool ended) onData
) async {
  print("I am HERE------------------------------------");
  
  // Create a NEW StreamController for each recording session
  final StreamController<Uint8List> pcmController = StreamController<Uint8List>();

  
  // Create Random 
  var random = Random();
  OsaBreathSimulator sim = OsaBreathSimulator(random);

  Directory dir = await getApplicationDocumentsDirectory();
  await _recorder.openRecorder();

  final List<Uint8List> buffer = [];
  StreamController<Uint8List> _pcmController = StreamController();


  // -------------------------------

  // ⚡ รับ PCM data จาก recorder
  pcmController.stream.listen((Uint8List chunk) {
    buffer.add(chunk);
  });

  // // ⚡ เริ่มอัดเสียงแบบ PCM stream
  await _recorder.startRecorder(
    codec: Codec.pcm16,               
    toStream: pcmController.sink,   
    numChannels: 1,
    sampleRate: 16000,
  );

  DateTime sessionStart = DateTime.now();

  while (timeRunning()) {
    print("Running : $timeRunning");
    DateTime shortStart = DateTime.now();

    // รอ 1 วิ
    await Future.delayed(Duration(seconds: 1));

    if (buffer.isNotEmpty) {
      Uint8List merged = Uint8List.fromList(
        buffer.expand((e) => e).toList(),
      );

      buffer.clear();

      // สร้างไฟล์ PCM 1 วินาที
      String path =
          "${dir.path}/part_${DateTime.now().millisecondsSinceEpoch}.pcm";

      File file = File(path);
      await file.writeAsBytes(merged);

      DateTime shortEnd = DateTime.now();
      double ramdomvalue = sim.nextValue();
      onData(path,ramdomvalue,shortStart, shortEnd, false);
    }
  }

  await _recorder.stopRecorder();
  await _recorder.closeRecorder();
  await pcmController.close();

  DateTime sessionEnd = DateTime.now();
  onData("",-1,sessionStart, sessionEnd, true);
}



/// -------------------------------------------------------------
/// Class จำลองลมหายใจผู้ป่วย OSA
/// -------------------------------------------------------------
class OsaBreathSimulator {
  final Random random;

  String state = "normal"; // current state
  int ticksLeft = 0;       // counter ระยะเวลา state
  double currentValue = 0; // ค่าลมหายใจปัจจุบัน

  OsaBreathSimulator(this.random) {
    _enterNormal();
  }

  /// รับค่า next breath
  double nextValue() {
    if (ticksLeft-- <= 0) {
      _nextState();
    }

    switch (state) {
      case "normal":
        return _normal();
      case "hypopnea":
        return _hypopneaDrop();
      case "apnea":
        return 0.0;
      case "recovery":
        return _recovery();
    }
    return 0.0;
  }

  /// -------------------------------------------------------------
  /// Logic เปลี่ยน state
  /// -------------------------------------------------------------
  void _nextState() {
    if (state == "normal") {
      if (random.nextDouble() < 0.15) { // 15% chance เปลี่ยนเป็น hypopnea
        _enterHypopnea();
      } else {
        _enterNormal();
      }
    } else if (state == "hypopnea") {
      _enterApnea();
    } else if (state == "apnea") {
      _enterRecovery();
    } else if (state == "recovery") {
      _enterNormal();
    }
  }

  /// -------------------------------------------------------------
  /// เข้าสู่ state ต่างๆ
  /// -------------------------------------------------------------
  void _enterNormal() {
    state = "normal";
    ticksLeft = 100 + random.nextInt(200); // 2–6 sec
    currentValue = 55 + random.nextDouble() * 20; // 55–75
  }

  void _enterHypopnea() {
    state = "hypopnea";
    ticksLeft = 100 + random.nextInt(200); // 2–6 sec
    currentValue = 30 + random.nextDouble() * 10; // เริ่ม 30–40
  }

  void _enterApnea() {
    state = "apnea";
    ticksLeft = 150 + random.nextInt(300); // 3–8 sec
  }

  void _enterRecovery() {
    state = "recovery";
    ticksLeft = 20 + random.nextInt(30); // 0.5–1 sec
  }

  /// -------------------------------------------------------------
  /// Generators ค่าลมหายใจแต่ละ state
  /// -------------------------------------------------------------
  double _normal() {
    double noise = random.nextDouble() * 4 - 2; // ±2
    double v = currentValue + noise;
    return double.parse(v.clamp(0, 100).toStringAsFixed(2));
  }

  double _hypopneaDrop() {
    currentValue -= (0.05 + random.nextDouble() * 0.1); // ลดเรื่อยๆ
    if (currentValue < 5) currentValue = 5;
    return double.parse(currentValue.clamp(0, 100).toStringAsFixed(2));
  }

  double _recovery() {
    double v = 80 + random.nextDouble() * 20; // spike 80–100
    return double.parse(v.clamp(0, 100).toStringAsFixed(2));
  }
}
