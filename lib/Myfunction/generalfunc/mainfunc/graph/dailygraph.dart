import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math' as math;

// ============================================================================
// SLEEP CONTROLLER - โหลด session หนึ่งครั้งแล้วเก็บ cache
// ============================================================================

class SleepController {
  Map<String, dynamic>? sessionData;
  List<DotDataPoint> allDots = [];
  List<DotDataPoint> overviewDots = [];
  int? _sessionId;

  bool get isLoaded => sessionData != null && allDots.isNotEmpty;

  Future<void> loadLatestSession() async {
    if (isLoaded) return; // ถ้าโหลดแล้วไม่ทำซ้ำ

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userEmail = user.email;
      final firestore = FirebaseFirestore.instance;

      final sessionsQuery = await firestore
          .collection('General user')
          .doc(userEmail)
          .collection('sleepsession')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (sessionsQuery.docs.isEmpty) return;

      final latestSession = sessionsQuery.docs.first;
      final sessionId = latestSession.get('id') as int;

      if (_sessionId == sessionId && allDots.isNotEmpty) {
        // ใช้ cache เดิม
        return;
      }

      allDots = await _fetchAllDots(latestSession.reference);
      overviewDots = _createOverviewData(allDots, 60);

      _sessionId = sessionId;
      sessionData = latestSession.data();
    } catch (e) {
      print('Error loading latest session: $e');
    }
  }

  void clearCache() {
    _sessionId = null;
    sessionData = null;
    allDots = [];
    overviewDots = [];
  }

  // เพิ่ม method สำหรับ force reload
  Future<void> forceReload() async {
    clearCache();
    await loadLatestSession();
  }

  // ========================================================================
  // FETCH ALL DOTS
  // ========================================================================

  Future<List<DotDataPoint>> _fetchAllDots(
      DocumentReference sessionDocRef) async {
    List<DotDataPoint> allDots = [];
    double currentHour = 0;

    final sleepdetailRef = sessionDocRef.collection('sleepdetail');
    final hourDocs = await sleepdetailRef.get();

    List<QueryDocumentSnapshot> hourDocsList = hourDocs.docs
        .where((doc) => doc.id != 'remainer')
        .toList();

    hourDocsList.sort((a, b) {
      int idA = int.tryParse(a.id.replaceFirst('hour', '')) ?? 0;
      int idB = int.tryParse(b.id.replaceFirst('hour', '')) ?? 0;
      return idA.compareTo(idB);
    });

    for (var hourDoc in hourDocsList) {
      final hourId = int.tryParse(hourDoc.id.replaceFirst('hour', '')) ?? 0;
      currentHour = hourId.toDouble();

      final minuteDocs = await sessionDocRef
          .collection('sleepdetail')
          .doc(hourDoc.id)
          .collection('minute')
          .get();

      final sortedMinutes = minuteDocs.docs.toList()
        ..sort((a, b) {
          int idA = a.get('id') as int? ?? 0;
          int idB = b.get('id') as int? ?? 0;
          return idA.compareTo(idB);
        });

      for (var minuteDoc in sortedMinutes) {
        final dots = minuteDoc.get('dot') as List<dynamic>? ?? [];
        for (var dot in dots) {
          if (dot is num) {
            final dotValue = dot.toDouble();
            allDots.add(DotDataPoint(
              x: currentHour,
              y: dotValue,
              category: _getCategory(dotValue),
            ));
          }
        }
      }
    }

    final remainerDoc = await sessionDocRef
        .collection('sleepdetail')
        .doc('remainer')
        .get();

    if (remainerDoc.exists) {
      final minute30Docs = await remainerDoc.reference
          .collection('minute30')
          .get();

      final sortedMinute30 = minute30Docs.docs.toList()
        ..sort((a, b) {
          int idA = a.get('id') as int? ?? 0;
          int idB = b.get('id') as int? ?? 0;
          return idA.compareTo(idB);
        });

      currentHour += 0.1;
      for (var minuteDoc in sortedMinute30) {
        final dots = minuteDoc.get('dot') as List<dynamic>? ?? [];
        for (var dot in dots) {
          if (dot is num) {
            final dotValue = dot.toDouble();
            allDots.add(DotDataPoint(
              x: currentHour,
              y: dotValue,
              category: _getCategory(dotValue),
            ));
          }
        }
      }

      final secondsDoc = await remainerDoc.reference
          .collection('seconds')
          .doc('seconds')
          .get();

      if (secondsDoc.exists) {
        final dots = secondsDoc.get('dot') as List<dynamic>? ?? [];
        for (var dot in dots) {
          if (dot is num) {
            final dotValue = dot.toDouble();
            allDots.add(DotDataPoint(
              x: currentHour,
              y: dotValue,
              category: _getCategory(dotValue),
            ));
          }
        }
      }
    }

    return allDots;
  }

  List<DotDataPoint> _createOverviewData(List<DotDataPoint> allDots, int groupSize) {
    if (allDots.isEmpty) return [];

    List<DotDataPoint> overviewDots = [];
    for (int i = 0; i < allDots.length; i += groupSize) {
      int endIndex =
          (i + groupSize < allDots.length) ? i + groupSize : allDots.length;
      List<DotDataPoint> group = allDots.sublist(i, endIndex);

      double avgY = group.map((d) => d.y).reduce((a, b) => a + b) / group.length;
      double avgX = group.map((d) => d.x).reduce((a, b) => a + b) / group.length;
      String avgCategory = _getCategory(avgY);

      overviewDots.add(DotDataPoint(
        x: avgX,
        y: avgY,
        category: avgCategory,
      ));
    }

    return overviewDots;
  }

  String _getCategory(double value) {
    if (0 <= value && value <= 25) return "Apnea";
    if (25 < value && value <= 50) return "Quiet";
    if (50 < value && value <= 75) return "Lound";
    if (75 < value && value <= 100) return "Very Lound";
    return "Unknown";
  }

  DateTime? _parseDateTime(dynamic timeRaw) {
    try {
      if (timeRaw is Timestamp) return timeRaw.toDate();
      if (timeRaw is String) return DateTime.parse(timeRaw);
      return null;
    } catch (_) {
      return null;
    }
  }

  String _formatTime(dynamic timeRaw) {
    final dt = _parseDateTime(timeRaw);
    if (dt == null) return '--:--';
    return DateFormat('h:mm a').format(dt);
  }

  // ==========================
  // PUBLIC UTILITY FUNCTIONS
  // ==========================

  Future<List<String>> getDateToday() async {
    if (!isLoaded) return ['--', '--'];
    final startTime = sessionData!['startTime'];
    final dt = _parseDateTime(startTime);
    if (dt == null) return ['--', '--'];
    return [
      DateFormat('EEEE d').format(dt),
      DateFormat('MMMM').format(dt),
    ];
  }

  Map<String, String> getSleepStartEnd() {
    if (!isLoaded) return {'startSession': '--:--', 'endSession': '--:--'};
    return {
      'startSession': _formatTime(sessionData!['startTime']),
      'endSession': _formatTime(sessionData!['endTime']),
    };
  }

  String getTotalSleepTime() {
    if (!isLoaded) return '--:--';
    final start = _parseDateTime(sessionData!['startTime']);
    final end = _parseDateTime(sessionData!['endTime']);
    if (start == null || end == null) return '--:--';
    final duration = end.difference(start);
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
  }

  Future<Map<String, CategoryDetail>> getCategoryDetails() async {
    if (!isLoaded) return {};
    final apneaCount = sessionData!['apnea'] as int? ?? 0;
    final quietCount = sessionData!['quiet'] as int? ?? 0;
    final loundCount = sessionData!['lound'] as int? ?? 0;
    final veryLoundCount = sessionData!['verylound'] as int? ?? 0;

    return {
      'apnea': CategoryDetail(
        color: Colors.blue,
        count: apneaCount,
        start: 0,
        end: 25,
        name: 'Apnea',
      ),
      'quiet': CategoryDetail(
        color: Colors.green,
        count: quietCount,
        start: 25,
        end: 50,
        name: 'Quiet',
      ),
      'lound': CategoryDetail(
        color: Colors.orange,
        count: loundCount,
        start: 50,
        end: 75,
        name: 'Lound',
      ),
      'veryLound': CategoryDetail(
        color: Colors.red,
        count: veryLoundCount,
        start: 75,
        end: 100,
        name: 'Very Lound',
      ),
    };
  }

  Future<SnoreStats> getSnoreStatistics() async {
    if (!isLoaded) return SnoreStats(totalSnoreTime: '--:--', snorePercentage: 0.0, totalSnoreDots: 0);
    final loundCount = sessionData!['lound'] as int? ?? 0;
    final veryLoundCount = sessionData!['verylound'] as int? ?? 0;
    final totalSnoreDots = loundCount + veryLoundCount;

    final totalSleepStr = getTotalSleepTime();
    final totalSleepMinutes = _parseTimeToMinutes(totalSleepStr);

    final snoreMinutes = totalSnoreDots / 60.0;
    final snorePercentage =
        totalSleepMinutes > 0 ? (snoreMinutes / totalSleepMinutes) * 100 : 0.0;

    final snoreHours = (snoreMinutes ~/ 60).toInt();
    final snoreMinutesRemainder = (snoreMinutes % 60).toInt();
    final totalSnoreTime =
        '$snoreHours:${snoreMinutesRemainder.toString().padLeft(2, '0')}';

    return SnoreStats(
      totalSnoreTime: totalSnoreTime,
      snorePercentage: double.parse(snorePercentage.toStringAsFixed(1)),
      totalSnoreDots: totalSnoreDots,
    );
  }

  Map<String, List<DotDataPoint>> getGraphData() {
    return {
      'allDots': allDots,
      'overviewDots': overviewDots,
    };
  }

  Future<bool> updateSessionNote(String newNote) async {
    try {
      final wordCount = newNote.trim().isEmpty
          ? 0
          : newNote.trim().split(RegExp(r'\s+')).length;
      if (wordCount > 100) {
        print('Note exceeds 100 words. Current: $wordCount words');
        return false;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userEmail = user.email;
      final firestore = FirebaseFirestore.instance;

      final sessionsQuery = await firestore
          .collection('General user')
          .doc(userEmail)
          .collection('sleepsession')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (sessionsQuery.docs.isEmpty) return false;

      final latestSession = sessionsQuery.docs.first;
      final oldNote = latestSession.get('note') as String? ?? '';

      if (oldNote == newNote) {
        print('Note unchanged. No update needed.');
        return true;
      }

      await latestSession.reference.update({'note': newNote});
      clearCache();

      print('Note updated successfully');
      return true;
    } catch (e) {
      print('Error updating note: $e');
      return false;
    }
  }

  double _parseTimeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return 0;
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours * 60 + minutes.toDouble();
    } catch (e) {
      return 0;
    }
  }

  // ========================================================================
  // MANUAL CHECK FOR NEW SESSION
  // ========================================================================

  // ✅ เช็คว่ามี session ใหม่หรือไม่ (ไม่ใช้ realtime listener)
  Future<bool> hasNewSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userEmail = user.email;
      final firestore = FirebaseFirestore.instance;

      final sessionsQuery = await firestore
          .collection('General user')
          .doc(userEmail)
          .collection('sleepsession')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (sessionsQuery.docs.isEmpty) return false;

      final latestSessionId = sessionsQuery.docs.first.get('id') as int;

      // เปรียบเทียบกับ sessionId ปัจจุบัน
      return _sessionId != latestSessionId;
    } catch (e) {
      print('Error checking new session: $e');
      return false;
    }
  }

  // ========================================================================
  // REALTIME LISTENER (Optional - ไม่ใช้ใน Manual mode)
  // ========================================================================

  StreamSubscription<QuerySnapshot>? _sleepSessionListener;

  void startListeningToSessions({VoidCallback? onUpdate}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEmail = user.email;
    final firestore = FirebaseFirestore.instance;

    _sleepSessionListener?.cancel();

    _sleepSessionListener = firestore
        .collection('General user')
        .doc(userEmail)
        .collection('sleepsession')
        .orderBy('id', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) return;

      final latestSessionId = snapshot.docs.first.get('id') as int?;

      if (_sessionId != latestSessionId) {
        clearCache();
        await loadLatestSession();
        if (onUpdate != null) onUpdate();
      }
    });
  }

  void stopListening() {
    _sleepSessionListener?.cancel();
    _sleepSessionListener = null;
  }
}

// ============================================================================
// LEGACY FUNCTIONS - Wrapper สำหรับ backward compatibility
// ============================================================================

Future<List<String>> getDateToday() async {
  final controller = SleepController();
  await controller.loadLatestSession();
  return controller.getDateToday();
}

Future<Map<String, String>> getSleepStartEnd() async {
  final controller = SleepController();
  await controller.loadLatestSession();
  return controller.getSleepStartEnd();
}

Future<String> getTotalSleepTime() async {
  final controller = SleepController();
  await controller.loadLatestSession();
  return controller.getTotalSleepTime();
}

Future<Map<String, CategoryDetail>> getCategoryDetails() async {
  final controller = SleepController();
  await controller.loadLatestSession();
  return controller.getCategoryDetails();
}

Future<SnoreStats> getSnoreStatistics() async {
  final controller = SleepController();
  await controller.loadLatestSession();
  return controller.getSnoreStatistics();
}

Future<Map<String, List<DotDataPoint>>> getGraphData() async {
  final controller = SleepController();
  await controller.loadLatestSession();
  return controller.getGraphData();
}

Future<bool> updateSessionNote(String newNote) async {
  final controller = SleepController();
  return controller.updateSessionNote(newNote);
}

// ============================================================================
// MODEL
// ============================================================================

class DotDataPoint {
  final double x;
  final double y;
  final String category;

  DotDataPoint({
    required this.x,
    required this.y,
    required this.category,
  });

  Color get categoryColor {
    switch (category) {
      case "Apnea":
        return Colors.blue;
      case "Quiet":
        return Colors.green;
      case "Lound":
        return Colors.orange;
      case "Very Lound":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class CategoryDetail {
  final Color color;
  final int count;
  final int start;
  final int end;
  final String name;

  CategoryDetail({
    required this.color,
    required this.count,
    required this.start,
    required this.end,
    required this.name,
  });
}

class SnoreStats {
  final String totalSnoreTime;
  final double snorePercentage;
  final int totalSnoreDots;

  SnoreStats({
    required this.totalSnoreTime,
    required this.snorePercentage,
    required this.totalSnoreDots,
  });
}

List<Color> getcategoryColorList() {
  final colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red
  ];
  return colors;
}

Color colorCal(double y) {
  if (0 <= y && y < 25) {
    return getcategoryColorList()[0];
  } else if (25 <= y && y < 50) {
    return getcategoryColorList()[1];
  } else if (50 <= y && y < 75) {
    return getcategoryColorList()[2];
  } else if (75 <= y && y < 100) {
    return getcategoryColorList()[3];
  }

  return Colors.grey;
}

// ============================================================================
// GRAPH WIDGET - ใช้ Controller แทน FutureBuilder
// ============================================================================

class GraphBuilder extends StatefulWidget {
  @override
  State<GraphBuilder> createState() => _GraphBuilderState();
}

class _GraphBuilderState extends State<GraphBuilder> {
  final controller = SleepController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await controller.loadLatestSession();
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (!controller.isLoaded || controller.allDots.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: buildGraphWidget(
            context: context,
            dots: controller.allDots,
            sessionData: controller.sessionData ?? {},
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// BUILD GRAPH WIDGET
// ============================================================================

Widget buildGraphWidget({
  required BuildContext context,
  required List<DotDataPoint> dots,
  required Map<String, dynamic> sessionData,
}) {
  if (dots.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('No data available'),
    );
  }

  final mediaWidth = MediaQuery.of(context).size.width;

  final controller = SleepController();
  final startTimeRaw = sessionData['startTime'];
  final endTimeRaw = sessionData['endTime'];
  final startDateTime = controller._parseDateTime(startTimeRaw);
  final endDateTime = controller._parseDateTime(endTimeRaw);

  int numBottomTitles = 1;
  if (startDateTime != null && endDateTime != null) {
    final totalMinutes = endDateTime.difference(startDateTime).inMinutes;
    numBottomTitles = (totalMinutes / 30).ceil() + 1;
  }

  double minGraphWidth = math.max(mediaWidth - 32, 320);
  double graphWidth;

  if (numBottomTitles < 6) {
    graphWidth = minGraphWidth;
  } else {
    graphWidth = math.max(minGraphWidth, numBottomTitles * 60.0);
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: graphWidth,
        height: 275,
        child: LineChart(
          _buildChartData(
            dots: dots,
            sessionData: sessionData,
            isCurved: false,
          ),
        ),
      ),
    ),
  );
}

// ============================================================================
// BUILD CHART DATA
// ============================================================================

LineChartData _buildChartData({
  required List<DotDataPoint> dots,
  required Map<String, dynamic> sessionData,
  bool isCurved = false,
}) {
  final controller = SleepController();
  final startTimeRaw = sessionData['startTime'];
  final endTimeRaw = sessionData['endTime'];
  final startDateTime = controller._parseDateTime(startTimeRaw);
  final endDateTime = controller._parseDateTime(endTimeRaw);

  if (startDateTime == null || endDateTime == null || dots.isEmpty) {
    return LineChartData(
      minX: 0,
      maxX: 1,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(spots: [const FlSpot(0, 50)])
      ],
    );
  }

  final totalMinutes = endDateTime.difference(startDateTime).inMinutes;

  final List<FlSpot> spots = [];
  if (dots.isNotEmpty) {
    for (int i = 0; i < dots.length; i++) {
      final fraction = (dots.length > 1) ? i / (dots.length - 1) : 0.0;
      final xPos = fraction * totalMinutes;
      spots.add(FlSpot(xPos, dots[i].y));
    }
  }

  final Map<double, String> labelPositions = {};
  for (int min = 0; min <= totalMinutes; min += 30) {
    final labelTime = startDateTime.add(Duration(minutes: min));
    final label = DateFormat('H:mm').format(labelTime);
    labelPositions[min.toDouble()] = label;
  }
  
  final endTimeLabel = DateFormat('H:mm').format(endDateTime);
  labelPositions[totalMinutes.toDouble()] = endTimeLabel;

  final List<Color> gradientColors = getcategoryColorList();

  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawHorizontalLine: true,
      horizontalInterval: 25,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.black.withOpacity(0.2),
          strokeWidth: 1,
          dashArray: [5],
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          strokeWidth: 0,
        );
      },
    ),
    titlesData: FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 30,
          getTitlesWidget: (value, meta) {
            if (labelPositions.containsKey(value)) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  labelPositions[value]!,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 25,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
    ),
    borderData: FlBorderData(show: true),
    minX: 0,
    maxX: totalMinutes.toDouble(),
    minY: 0,
    maxY: 100,
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: isCurved,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        barWidth: 2.5,
        dotData: FlDotData(show: false),
        shadow: Shadow(
          blurRadius: 8,
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 4),
        ),
      ),
    ],
    lineTouchData: LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            int closestIndex = 0;
            double minDist = double.infinity;
            for (int i = 0; i < spots.length; i++) {
              final dist = (spots[i].x - spot.x).abs();
              if (dist < minDist) {
                minDist = dist;
                closestIndex = i;
              }
            }

            String timeLabel = '--:--';
            final minutesOffset = spots[closestIndex].x.toInt();
            final labelTime =
                startDateTime.add(Duration(minutes: minutesOffset));
            timeLabel = DateFormat('H:mm').format(labelTime);

            return LineTooltipItem(
              'at $timeLabel : ${spot.y.toStringAsFixed(1)} lound',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
        getTooltipColor: (LineBarSpot touchedSpot) {
          return colorCal(touchedSpot.y);
        },
        tooltipBorderRadius: BorderRadius.circular(8),
      ),
      getTouchLineStart: (barData, spotIndex) => 0,
      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: colorCal(barData.spots[index].y),
              strokeWidth: 2,
              dashArray: [4, 4],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorCal(spot.y),
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
          );
        }).toList();
      },
    ),
  );
}

// ============================================================================
// LEGEND
// ============================================================================

Widget _buildLegendSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Legend',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _LegendItem(label: 'Apnea', color: Colors.blue),
          _LegendItem(label: 'Quiet', color: Colors.green),
          _LegendItem(label: 'Lound', color: Colors.orange),
          _LegendItem(label: 'Very Lound', color: Colors.red),
        ],
      ),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}