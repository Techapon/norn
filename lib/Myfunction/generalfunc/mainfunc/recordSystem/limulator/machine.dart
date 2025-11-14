import 'dart:math';

Future<void> recordVoiceMachince(
  bool Function() timeRunning,
  void Function(double voiceValue, DateTime voiceStart, DateTime voiceEnd, bool ended) onData
) async {
  var random = Random();

  DateTime sessionStart = DateTime.now();
  while (timeRunning()) {
    DateTime shortStart = DateTime.now();
    await Future.delayed(Duration(microseconds: 10));

    // machine Simulator
    // double randomNumber = double.parse((random.nextDouble() * 10).toStringAsFixed(2));
    double randomNumber = randomBreathValue(random);

    DateTime shortEnd = DateTime.now();

    onData(randomNumber, shortStart, shortEnd, false);
  }
  DateTime sessionEnd = DateTime.now();
  onData(-1, sessionStart, sessionEnd, true);
}

double randomBreathValue(Random random) {
  double r = random.nextDouble();
  double value;
  if (r < 0.05) { // 5% pause (apnea)
     value = 0.0; // หยุดหายใจ
  } else if (r < 0.15) { // 10% shallow (hypopnea)
     value = 10 + random.nextDouble() * 20; // 10–30
  } else if (r < 0.20) { // 5% recovery spike
     value = 80 + random.nextDouble() * 20; // 80–100
  } else { // normal
     value = 50 + random.nextDouble() * 30; // 50–80
  }
  return double.parse(value.toStringAsFixed(2));
}
