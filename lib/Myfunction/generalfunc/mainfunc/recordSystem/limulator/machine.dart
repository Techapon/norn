import 'dart:math';

/// -------------------------------------------------------------
/// Function จำลองการบันทึกลมหายใจผู้ป่วย OSA
/// -------------------------------------------------------------
Future<void> recordVoiceMachince(
  bool Function() timeRunning,
  void Function(double voiceValue, DateTime voiceStart, DateTime voiceEnd, bool ended) onData
) async {
  var random = Random();
  DateTime sessionStart = DateTime.now();

  // สร้าง simulator
  OsaBreathSimulator sim = OsaBreathSimulator(random);

  // loop จนกว่า timeRunning() return false
  while (timeRunning()) {
    DateTime shortStart = DateTime.now();
    await Future.delayed(Duration(microseconds: 500)); // 

    double value = sim.nextValue(); // รับค่าลมหายใจสมจริง 0–100
    DateTime shortEnd = DateTime.now();

    onData(value, shortStart, shortEnd, false);
  }

  // จบ session
  DateTime sessionEnd = DateTime.now();
  onData(-1, sessionStart, sessionEnd, true);
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
