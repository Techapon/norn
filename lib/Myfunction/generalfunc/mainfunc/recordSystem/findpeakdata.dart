import 'dart:math';

List<double> analyzePeakValue(
  List<double> data, {
  int window = 2,
  double multiplier = 3,
  double minPromAbs = 1,
}) {
  List<double> dot = [];

  if (data.isEmpty) return dot;

  for (int i = 0; i < data.length; i++) {
    int start = max(0, i - window);
    int end = min(data.length - 1, i + window);

    // --- neighbors (ไม่รวมค่าปัจจุบัน) ---
    List<double> neighbors = [];
    for (int j = start; j <= end; j++) {
      if (j == i) continue;
      neighbors.add(data[j]);
    }
    if (neighbors.isEmpty) continue;

    // --- mean, sd ---
    double mean = neighbors.reduce((a, b) => a + b) / neighbors.length;
    double variance = neighbors
        .map((x) => pow(x - mean, 2))
        .reduce((a, b) => a + b) / neighbors.length;
    double sd = sqrt(variance);

    double prom = (data[i] - mean).abs();

    // --- ตรวจ spike ---
    bool condSd = (sd > 0) ? prom >= sd * multiplier : false;
    bool condAbs = prom >= minPromAbs;

    if ((sd > 0 && condSd && condAbs) || (sd == 0 && condAbs && prom > 0)) {
      // --- เก็บ start/end รอบ spike ---
      int? startSpike = (i - 1) < 0 ? null : i - 1;
      int? endSpike = (i + 1) >= data.length ? null : i + 1;

      if (startSpike != null) dot.add(data[startSpike]);
      dot.add(data[i]);
      if (endSpike != null) dot.add(data[endSpike]);
    }
  }

  return dot;
}