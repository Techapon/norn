import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math' as math;

// ============================================================================
// CACHING - ดึงข้อมูลเพียงครั้งเดียว
// ============================================================================

class SleepDataCache {
  static int? lastSessionId;
  static List<DotDataPoint>? cachedAllDots;
  static List<DotDataPoint>? cachedOverviewDots;
  static Map<String, dynamic>? cachedSessionData;

  static void clear() {
    lastSessionId = null;
    cachedAllDots = null;
    cachedOverviewDots = null;
    cachedSessionData = null;
  }

  static bool isValid(int currentSessionId) {
    return lastSessionId == currentSessionId && cachedAllDots != null;
  }
}

// ============================================================================
// ✅ MAIN FUNCTION - ดึงข้อมูลเพียงครั้งเดียว
// ============================================================================

/// ✅ ฟังก์ชั่นหลักในการดึงข้อมูล (ดึงเพียงครั้งเดียว)
/// ทุก function อื่นจะใช้ข้อมูลจากที่นี่เท่านั้น
Future<Map<String, dynamic>> getLatestSleepSessionWithCache() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final userEmail = user.email;
    final firestore = FirebaseFirestore.instance;

    // ดึง session ล่าสุด
    final sessionsQuery = await firestore
        .collection('General user')
        .doc(userEmail)
        .collection('sleepsession')
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    if (sessionsQuery.docs.isEmpty) return {};

    final latestSession = sessionsQuery.docs.first;
    final sessionId = latestSession.get('id') as int;

    // ✅ ตรวจสอบ cache - ถ้า session ไม่เปลี่ยน ใช้อันเก่า
    if (SleepDataCache.isValid(sessionId)) {
      return {
        'allDots': SleepDataCache.cachedAllDots,
        'overviewDots': SleepDataCache.cachedOverviewDots,
        'sessionData': SleepDataCache.cachedSessionData,
      };
    }

    // ✅ ดึงข้อมูล dots เมื่อ session เปลี่ยน
    final allDots = await _fetchAllDots(latestSession.reference);
    final overviewDots = _createOverviewData(allDots, 60);

    // เก็บใน cache
    SleepDataCache.lastSessionId = sessionId;
    SleepDataCache.cachedAllDots = allDots;
    SleepDataCache.cachedOverviewDots = overviewDots;
    SleepDataCache.cachedSessionData = latestSession.data();

    return {
      'allDots': allDots,
      'overviewDots': overviewDots,
      'sessionData': latestSession.data(),
    };
  } catch (e) {
    print('❌ Error: $e');
    return {};
  }
}

// ============================================================================
// HELPER FUNCTIONS - ดึงข้อมูล dots
// ============================================================================

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

  // ดึง hour data
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

  // ดึง remainer data
  final remainerDoc = await sessionDocRef
      .collection('sleepdetail')
      .doc('remainer')
      .get();

  if (remainerDoc.exists) {
    // ✅ Read from minute30 collection (30-minute intervals)
    final minute30Docs = await remainerDoc.reference
        .collection('minute30')
        .get();

    final sortedMinute30 = minute30Docs.docs.toList()
      ..sort((a, b) {
        int idA = a.get('id') as int? ?? 0;
        int idB = b.get('id') as int? ?? 0;
        return idA.compareTo(idB);
      });

    // Continue from last hour
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
      // currentHour += 0.1; // ใช้ค่าเดิม
      for (var dot in dots) {
        if (dot is num) {
          final dotValue = dot.toDouble();
          allDots.add(DotDataPoint(
            x: currentHour, // ใช้ค่า x เดิม
            y: dotValue,
            category: _getCategory(dotValue),
          ));
        }
      }
    }
  }

  return allDots;
}

List<DotDataPoint> _createOverviewData(
    List<DotDataPoint> allDots, int groupSize) {
  if (allDots.isEmpty) return [];

  List<DotDataPoint> overviewDots = [];

  for (int i = 0; i < allDots.length; i += groupSize) {
    int endIndex =
        (i + groupSize < allDots.length) ? i + groupSize : allDots.length;
    List<DotDataPoint> group = allDots.sublist(i, endIndex);

    double avgY = group.map((d) => d.y).reduce((a, b) => a + b) / group.length;
    
    // **แก้ไข:** ใช้ค่า X ของจุดแรกในกลุ่มสำหรับ Overview 
    // หรือค่าเฉลี่ย X
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

// ============================================================================
// HELPER - Format time
// ============================================================================

String _formatTime(dynamic timeRaw) {
  try {
    DateTime dateTime;

    if (timeRaw is Timestamp) {
      dateTime = timeRaw.toDate();
    } else if (timeRaw is String) {
      dateTime = DateTime.parse(timeRaw);
    } else {
      return '--:--';
    }

    return DateFormat('h:mm a').format(dateTime);
  } catch (e) {
    return '--:--';
  }
}

DateTime? _parseDateTime(dynamic timeRaw) {
  try {
    if (timeRaw is Timestamp) {
      return timeRaw.toDate();
    } else if (timeRaw is String) {
      return DateTime.parse(timeRaw);
    }
    return null;
  } catch (e) {
    return null;
  }
}

// ============================================================================
// FUNCTION 1: Get Date Today
// ============================================================================

/// ✅ ได้วันที่ เช่น "Thursday 14 November"
/// ดึงข้อมูลเพียงครั้งเดียว
Future<List<String>> getDateToday() async {
  final data = await getLatestSleepSessionWithCache();
  final sessionData = data['sessionData'] as Map<String, dynamic>? ?? {};

  final startTimeRaw = sessionData['startTime'];

  try {
    final dateTime = _parseDateTime(startTimeRaw);
    if (dateTime == null) return ['--', '--'];
    return [
      DateFormat('EEEE d').format(dateTime),  // วันและวันที่
      DateFormat('MMMM').format(dateTime),    // เดือน
    ];
  } catch (e) {
    return ['--', '--'];
  }
}

// ============================================================================
// FUNCTION 2: Get Sleep Time (Start & End)
// ============================================================================

/// ✅ ได้เวลาเริ่มและสิ้นสุด เช่น "10:00 pm - 7:30 am"
/// ดึงข้อมูลเพียงครั้งเดียว
Future<Map<String, String>> getSleepStartEnd() async {
  final data = await getLatestSleepSessionWithCache();
  final sessionData = data['sessionData'] as Map<String, dynamic>? ?? {};

  final startTimeRaw = sessionData['startTime'];
  final endTimeRaw = sessionData['endTime'];

  return {
    'startSession': _formatTime(startTimeRaw),
    'endSession': _formatTime(endTimeRaw),
  };
}

// ============================================================================
// FUNCTION 3: Get Total Sleep Time
// ============================================================================

/// ✅ ได้ระยะเวลานอน เช่น "7:05"
/// ดึงข้อมูลเพียงครั้งเดียว
Future<String> getTotalSleepTime() async {
  final data = await getLatestSleepSessionWithCache();
  final sessionData = data['sessionData'] as Map<String, dynamic>? ?? {};

  final startTimeRaw = sessionData['startTime'];
  final endTimeRaw = sessionData['endTime'];

  try {
    final start = _parseDateTime(startTimeRaw);
    final end = _parseDateTime(endTimeRaw);

    if (start == null || end == null) return '--:--';

    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '$hours:${minutes.toString().padLeft(2, '0')}';
  } catch (e) {
    return '--:--';
  }
}

// ============================================================================
// FUNCTION 4: Get Category Details
// ============================================================================

/// ✅ ได้ข้อมูล category จาก session data
/// apnea, quiet, lound, verylound count
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

Future<Map<String, CategoryDetail>> getCategoryDetails() async {
  final data = await getLatestSleepSessionWithCache();
  final sessionData = data['sessionData'] as Map<String, dynamic>? ?? {};

  // ✅ ดึงค่าจาก session data (ไม่ใช่จาก dots)
  final apneaCount = sessionData['apnea'] as int? ?? 0;
  final quietCount = sessionData['quiet'] as int? ?? 0;
  final loundCount = sessionData['lound'] as int? ?? 0;
  final veryLoundCount = sessionData['verylound'] as int? ?? 0;

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

// ============================================================================
// FUNCTION 5: Get Snore Statistics
// ============================================================================

/// ✅ SnoreStats - ข้อมูล snore ทั้งหมด
class SnoreStats {
  final String totalSnoreTime; // เช่น "1:23"
  final double snorePercentage; // เช่น 15.5 (%)
  final int totalSnoreDots; // จำนวน lound + very lound

  SnoreStats({
    required this.totalSnoreTime,
    required this.snorePercentage,
    required this.totalSnoreDots,
  });
}

/// ✅ ได้สถิติการกรนทั้งหมด
/// - เวลาการกรนทั้งหมด
/// - เปอร์เซ็นการกรน
/// ดึงข้อมูลเพียงครั้งเดียว
Future<SnoreStats> getSnoreStatistics() async {
  final data = await getLatestSleepSessionWithCache();
  final sessionData = data['sessionData'] as Map<String, dynamic>? ?? {};

  // ✅ ดึงจาก session data
  final loundCount = sessionData['lound'] as int? ?? 0;
  final veryLoundCount = sessionData['verylound'] as int? ?? 0;
  final totalSnoreDots = loundCount + veryLoundCount;

  // ✅ คำนวณ total sleep time เพื่อหา percentage
  final totalSleepStr = await getTotalSleepTime();
  final totalSleepMinutes = _parseTimeToMinutes(totalSleepStr);

  // ✅ แต่ละ dot = 1 วินาที → แปลงเป็นนาที
  final snoreMinutes = totalSnoreDots / 60.0;
  final snorePercentage =
      totalSleepMinutes > 0 ? (snoreMinutes / totalSleepMinutes) * 100 : 0.0;

  // ✅ แปลง snore minutes เป็น HH:MM
  final snoreHours = (snoreMinutes ~/ 60).toInt();
  // final snoreSecondsRemainder = // ไม่จำเป็นต้องใช้ เพราะต้องการเป็น HH:MM
  //     ((snoreMinutes % 60) * 60).toInt() % 60;
  final snoreMinutesRemainder = (snoreMinutes % 60).toInt();
  final totalSnoreTime =
      '$snoreHours:${snoreMinutesRemainder.toString().padLeft(2, '0')}';

  return SnoreStats(
    totalSnoreTime: totalSnoreTime,
    snorePercentage: double.parse(snorePercentage.toStringAsFixed(1)),
    totalSnoreDots: totalSnoreDots,
  );
}

// Helper: แปลง "H:MM" เป็น minutes
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

// ============================================================================
// FUNCTION 6: Get Graph Data (allDots & overviewDots)
// ============================================================================

/// ✅ ได้ข้อมูล graph
/// - allDots: ข้อมูลทั้งหมด
/// - overviewDots: ข้อมูล overview (ลด resolution)
Future<Map<String, List<DotDataPoint>>> getGraphData() async {
  final data = await getLatestSleepSessionWithCache();

  return {
    'allDots': data['allDots'] as List<DotDataPoint>? ?? [],
    'overviewDots': data['overviewDots'] as List<DotDataPoint>? ?? [],
  };
}


// ============================================================================
// FUNCTION 7: Update Note
// ============================================================================

/// ✅ อัปเดต note (Max 100 คำ)
/// ถ้าเปลี่ยนแปลง: update + clear cache
/// ถ้าไม่เปลี่ยน: ไม่ update
Future<bool> updateSessionNote(String newNote) async {
  try {
    // Validate max 100 words
    final wordCount = newNote.trim().isEmpty
        ? 0
        : newNote.trim().split(RegExp(r'\s+')).length;
    if (wordCount > 100) {
      print('❌ Note exceeds 100 words. Current: $wordCount words');
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userEmail = user.email;
    final firestore = FirebaseFirestore.instance;

    // ดึง session ล่าสุด
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

    // ✅ ตรวจสอบการเปลี่ยนแปลง
    if (oldNote == newNote) {
      print('ℹ️ Note unchanged. No update needed.');
      return true;
    }

    // ✅ Update
    await latestSession.reference.update({'note': newNote});

    // ✅ Clear cache
    SleepDataCache.clear();

    print('✓ Note updated successfully');
    return true;
  } catch (e) {
    print('❌ Error updating note: $e');
    return false;
  }
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
        return Colors.blue; // **แก้ไข:** ใช้ Colors.blue ตาม CategoryDetail
      case "Quiet":
        return Colors.green; // **แก้ไข:** ใช้ Colors.green ตาม CategoryDetail
      case "Lound":
        return Colors.orange;
      case "Very Lound":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

}

List<Color> getcategoryColorList() {
  final corlors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red
  ];
  return corlors;
}

Color colorCal(double y) {
  if (0 <= y && y < 25) {
    return getcategoryColorList()[0];
  }else if (25 <= y && y < 50) {
    return getcategoryColorList()[1];
  }else if (50 <= y && y < 75) {
    return getcategoryColorList()[2];
  }else if (75 <= y && y < 100) {
    return getcategoryColorList()[3];
  }

  return Colors.grey;
}

// ============================================================================
// GRAPH WIDGET WITH MODE TOGGLE
// ============================================================================

// ✅ SINGLE NORMAL MODE - No mode toggle
class GraphBuilder extends StatefulWidget {
  @override
  State<GraphBuilder> createState() => _GraphBuilderState();
}

class _GraphBuilderState extends State<GraphBuilder> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getLatestSleepSessionWithCache(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('❌ เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}'),
          );
        }

        final data = snapshot.data;
        if (data == null || data['allDots'] == null) {
          return const Center(child: Text('ไม่พบข้อมูล'));
        }

        final allDots = data['allDots'] as List<DotDataPoint>? ?? [];
        final sessionData = data['sessionData'] as Map<String, dynamic>? ?? {};

        if (allDots.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูล'));
        }

        return Column(
          // this graph shit
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 0),
              child: _buildGraphWidget(
                context: context,
                dots: allDots,
                sessionData: sessionData,
              ),
            ),

            // this shit
            // const SizedBox(height: 24),
            // _buildLegendSection(),
          ],
        );
      },
    );
  }
}

// ------------------------------
//      Build Graph
// ------------------------------

Widget _buildGraphWidget({
  required BuildContext context,
  required List<DotDataPoint> dots,
  required Map<String, dynamic> sessionData,
}) {
  if (dots.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('ยังไม่มีข้อมูล'),
    );
  }

  final mediaWidth = MediaQuery.of(context).size.width;
  final graphWidth = math.max(mediaWidth - 32, 320.0);

  // ✅ Single normal mode: scrollable if data is wide
  final chart = SizedBox(
    width: graphWidth,
    height: 300,
    child: LineChart(
      _buildChartData(
        dots: dots,
        sessionData: sessionData,
        isCurved: false,
      ),
    ),
  );

  // If data is wide, make it horizontally scrollable
  if (dots.length > 500) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: math.max(graphWidth, dots.length * 2.0),
          height: 300,
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

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: chart,
  );
}

LineChartData _buildChartData({
  required List<DotDataPoint> dots,
  required Map<String, dynamic> sessionData,
  bool isCurved = false,
}) {
  // Parse DateTime from session data
  final startTimeRaw = sessionData['startTime'];
  final endTimeRaw = sessionData['endTime'];
  final startsess = _parseDateTime(startTimeRaw);
  final endsess = _parseDateTime(endTimeRaw);

  if (startsess == null || endsess == null || dots.isEmpty) {
    // Fallback to simple sequential mapping if no time data
    final spots = dots
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.y))
        .toList();
    return _buildChartDataWithSpots(spots, dots, {}, [], isCurved);
  }

  // Calculate total duration
  final totalDurationMinutes = endsess.difference(startsess).inMinutes.toDouble();

  // Group dots into 30-minute intervals and create aligned positions
  final Map<int, DateTime> indexToTime = {};
  final Map<int, double> indexToAlignedX = {};
  final List<FlSpot> spots = [];
  
  // Calculate 30-minute interval boundaries
  final List<DateTime> intervalBoundaries = [];
  DateTime currentInterval = DateTime(
    startsess.year,
    startsess.month,
    startsess.day,
    startsess.hour,
    (startsess.minute ~/ 30) * 30, // Round down to nearest :00 or :30
    0,
  );
  
  while (currentInterval.isBefore(endsess) || currentInterval.isAtSameMomentAs(endsess)) {
    intervalBoundaries.add(currentInterval);
    currentInterval = currentInterval.add(const Duration(minutes: 30));
  }
  
  // If end time doesn't align with interval, add it
  if (intervalBoundaries.isEmpty || intervalBoundaries.last.isBefore(endsess)) {
    intervalBoundaries.add(endsess);
  }

  // Map each dot to its time and aligned x-position
  // Track which interval each dot belongs to and ensure first dot aligns with boundary
  final Map<int, int> dotToIntervalIndex = {};
  final Map<int, List<int>> intervalToDots = {};
  
  // First pass: assign dots to intervals
  for (int i = 0; i < dots.length; i++) {
    // Calculate time for this dot
    final fraction = (dots.length > 1) ? i / (dots.length - 1) : 0.0;
    final minutesOffset = fraction * totalDurationMinutes;
    final dotTime = startsess.add(Duration(minutes: minutesOffset.toInt()));
    indexToTime[i] = dotTime;
    
    // Find which 30-minute interval this dot belongs to
    int intervalIndex = 0;
    for (int j = 0; j < intervalBoundaries.length - 1; j++) {
      if (dotTime.isBefore(intervalBoundaries[j + 1])) {
        intervalIndex = j;
        break;
      } else if (dotTime.isAtSameMomentAs(intervalBoundaries[j + 1])) {
        // If exactly at boundary, assign to next interval
        intervalIndex = j + 1;
        break;
      }
      intervalIndex = j + 1;
    }
    // Clamp to valid range
    if (intervalIndex >= intervalBoundaries.length) {
      intervalIndex = intervalBoundaries.length - 1;
    }
    
    dotToIntervalIndex[i] = intervalIndex;
    intervalToDots.putIfAbsent(intervalIndex, () => []).add(i);
  }
  
  // Second pass: calculate aligned x-positions
  // First dot in each interval aligns with interval start
  for (int i = 0; i < dots.length; i++) {
    final intervalIndex = dotToIntervalIndex[i]!;
    final intervalStartX = intervalIndex.toDouble();
    final intervalEndX = (intervalIndex + 1).toDouble();
    
    final dotTime = indexToTime[i]!;
    final intervalStartTime = intervalBoundaries[intervalIndex];
    final intervalEndTime = intervalIndex < intervalBoundaries.length - 1
        ? intervalBoundaries[intervalIndex + 1]
        : endsess;
    
    // Check if this is the first dot in this interval
    final dotsInInterval = intervalToDots[intervalIndex]!;
    final isFirstInInterval = dotsInInterval.first == i;
    
    double alignedX;
    if (isFirstInInterval) {
      // First dot in interval aligns exactly with interval start
      alignedX = intervalStartX;
    } else if (intervalIndex < intervalBoundaries.length - 1) {
      // Calculate position within current interval
      final intervalDuration = intervalEndTime.difference(intervalStartTime).inMinutes;
      if (intervalDuration > 0) {
        final timeInInterval = dotTime.difference(intervalStartTime).inMinutes;
        final fractionInInterval = timeInInterval / intervalDuration;
        // Ensure we don't go beyond interval end
        final clampedFraction = fractionInInterval.clamp(0.0, 1.0);
        alignedX = intervalStartX + (clampedFraction * (intervalEndX - intervalStartX));
      } else {
        alignedX = intervalStartX;
      }
    } else {
      // Last interval - align with end
      alignedX = intervalEndX;
    }
    
    indexToAlignedX[i] = alignedX;
    spots.add(FlSpot(alignedX, dots[i].y));
  }

  return _buildChartDataWithSpots(
    spots, 
    dots, 
    indexToTime, 
    intervalBoundaries,
    isCurved,
  );
}

LineChartData _buildChartDataWithSpots(
  List<FlSpot> spots,
  List<DotDataPoint> dots,
  Map<int, DateTime> indexToTime,
  List<DateTime> intervalBoundaries,
  bool isCurved,
) {
  // Pre-calculate all label positions and times to avoid duplicates
  final Map<double, String> labelPositions = {};
  final Set<String> usedLabels = {}; // Track used labels to prevent duplicates
  
  if (intervalBoundaries.isNotEmpty) {
    // Add labels at each interval boundary and :30 marks
    for (int i = 0; i < intervalBoundaries.length; i++) {
      final boundary = intervalBoundaries[i];
      
      // Determine if this boundary is at :00 or :30
      final isAtHalfHour = boundary.minute == 30;
      final isAtFullHour = boundary.minute == 0;
      
      if (isAtFullHour || isAtHalfHour) {
        // Use the actual boundary time
        final label = DateFormat.Hm().format(boundary);
        
        // Only add if we haven't used this label before
        if (!usedLabels.contains(label)) {
          labelPositions[i.toDouble()] = label;
          usedLabels.add(label);
        }
      } else {
        // Round to nearest :00
        final roundedTime = DateTime(
          boundary.year,
          boundary.month,
          boundary.day,
          boundary.hour,
          0,
          0,
        );
        final label = DateFormat.Hm().format(roundedTime);
        
        if (!usedLabels.contains(label)) {
          labelPositions[i.toDouble()] = label;
          usedLabels.add(label);
        }
      }
      
      // Add :30 label between boundaries if there's a next boundary
      if (i < intervalBoundaries.length - 1) {
        final nextBoundary = intervalBoundaries[i + 1];
        final duration = nextBoundary.difference(boundary).inMinutes;
        
        if (duration >= 30) {
          // Calculate :30 time from current boundary
          final halfTime = DateTime(
            boundary.year,
            boundary.month,
            boundary.day,
            boundary.hour,
            boundary.minute,
            0,
          ).add(Duration(minutes: 30));
          
          // Only add if it doesn't exceed next boundary
          if (halfTime.isBefore(nextBoundary) || halfTime.isAtSameMomentAs(nextBoundary)) {
            final halfLabel = DateFormat.Hm().format(halfTime);
            
            // Only add if we haven't used this label before
            if (!usedLabels.contains(halfLabel)) {
              labelPositions[i.toDouble() + 0.5] = halfLabel;
              usedLabels.add(halfLabel);
            }
          }
        }
      }
    }
  }
  
  // final colors = dots.map((d) => d.categoryColor).toList();
  final List<Color> gradientColors = getcategoryColorList();
  // final gradientColors = colors.isEmpty
  //     ? [Colors.blue, Colors.blue]
  //     : colors.length == 1
  //         ? [colors.first, colors.first]
  //         : colors;
  // final stops = gradientColors.length <= 1
  //     ? const [0.0, 1.0]
  //     : List<double>.generate(
  //         gradientColors.length,
  //         (i) => i / (gradientColors.length - 1),
  //       );

  return LineChartData(
    clipData: FlClipData.none(),

    gridData: FlGridData(show: true),
    titlesData: FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 0.5, // Show label every 0.5 units (30-minute intervals)
          getTitlesWidget: (value, meta) {
            // Round to nearest 0.5 to check if we're at a :00 or :30 mark
            final roundedValue = (value * 2).round() / 2.0;
            if ((value - roundedValue).abs() > 0.05) {
              return const SizedBox.shrink();
            }
            
            // Check if we have a pre-calculated label for this position
            if (labelPositions.containsKey(roundedValue)) {
              final label = labelPositions[roundedValue]!;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10),
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
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            if (value % 25 != 0) {
              return const SizedBox.shrink();
            }
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
    ),
    borderData: FlBorderData(show: true),
    minX: spots.isEmpty ? 0 : spots.map((s) => s.x).reduce(math.min),
    maxX: spots.isEmpty ? 0 : spots.map((s) => s.x).reduce(math.max),
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
          // stops: [0,0.25,0.5,0.75,1.0],
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
            // Find the original dot index from the spot's x position
            int originalIndex = 0;
            double minDistance = double.infinity;
            for (int i = 0; i < spots.length; i++) {
              final distance = (spots[i].x - spot.x).abs();
              if (distance < minDistance) {
                minDistance = distance;
                originalIndex = i;
              }
            }
            
            String label = '--:--';
            if (indexToTime.containsKey(originalIndex)) {
              final time = indexToTime[originalIndex]!;
              label = DateFormat.Hm().format(time);
            }
            
            return LineTooltipItem(
              '$label : ${spot.y.toStringAsFixed(1)}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  radius:4,                       
                  color: colorCal(spot.y),         
                  strokeWidth:1,
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

// this shit

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
