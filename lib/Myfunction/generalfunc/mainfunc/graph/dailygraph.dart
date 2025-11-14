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
    final minute10Docs = await remainerDoc.reference
        .collection('minute10')
        .get();

    final sortedMinute10 = minute10Docs.docs.toList()
      ..sort((a, b) {
        int idA = a.get('id') as int? ?? 0;
        int idB = b.get('id') as int? ?? 0;
        return idA.compareTo(idB);
      });

    // เนื่องจาก currentHour เป็น 'hour' ID ก่อนหน้านี้
    // ต้องอัพเดตค่า x ให้เป็นค่าที่ถูกต้องสำหรับ remainer
    // การเพิ่ม 0.1 อาจไม่ถูกต้อง 100% ขึ้นอยู่กับรูปแบบข้อมูล
    // แต่เพื่อรักษา logic เดิม:
    // currentHour += 0.1; // ใช้ค่าเดิม
    
    // Logic: ให้จุด remainer ต่อจากจุดสุดท้ายของ hour สุดท้าย
    // แต่เนื่องจากโค้ดใช้ currentHour สำหรับ X-axis label ในกราฟ (hour:00) 
    // เราจะใช้ logic เดิมและยอมรับว่าการแสดงผล X-axis อาจไม่ตรงใน detail mode
    
    // ใช้ค่า x เป็น index แทนเพื่อวาดกราฟที่ถูกต้อง
    // แต่เนื่องจากเราใช้ `e.key.toDouble()` ใน `_buildGraphView` 
    // เราจะใช้ logic การเก็บค่า x ที่อาจจะใช้สำหรับ label
    
    currentHour += 0.1;
    for (var minuteDoc in sortedMinute10) {
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
Future<Map<String, String>> getSleepTime() async {
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


// ============================================================================
// GRAPH WIDGET WITH MODE TOGGLE
// ============================================================================

class GraphWithModeToggle extends StatefulWidget {
  @override
  State<GraphWithModeToggle> createState() => _GraphWithModeToggleState();
}

class _GraphWithModeToggleState extends State<GraphWithModeToggle> {
  // ✅ ตัวแปรเก็บ mode (true = overview, false = detail)
  bool isOverviewMode = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<DotDataPoint>>>(
        // ✅ เรียก getGraphData()
        future: getGraphData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('❌ เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('ไม่พบข้อมูล'));
          }

          // ✅ ดึงข้อมูล
          final graphData = snapshot.data!;
          final allDots = graphData['allDots']!;
          final overviewDots = graphData['overviewDots']!;

          if (allDots.isEmpty) {
            return Center(child: Text('ไม่มีข้อมูล'));
          }

          // ✅ เลือก display data ตามโหมด
          final displayDots = isOverviewMode ? overviewDots : allDots;

          return _buildGraphView(context, displayDots, isOverviewMode);
        },
      );
  }

  // ✅ Build graph view
  Widget _buildGraphView(
      BuildContext context, List<DotDataPoint> displayDots, bool isOverviewMode) {
    final availableWidth = math.max(MediaQuery.of(context).size.width - 32, 320.0);
    final graphWidth = isOverviewMode
        ? availableWidth
        : math.max(availableWidth, 6500.0);

    // ✅ Convert dots เป็น FlSpot
    final spots = displayDots
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.y))
        .toList();

    // ✅ สีสำหรับ gradient
    if (displayDots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('ไม่มีข้อมูลสำหรับโหมดนี้'),
        ),
      );
    }

    final baseColors = displayDots.map((d) => d.categoryColor).toList();

    final gradientColors = () {
      if (baseColors.isEmpty) {
        return [Colors.blue, Colors.blue];
      }
      if (baseColors.length == 1) {
        return [baseColors.first, baseColors.first];
      }
      return baseColors;
    }();

    final stops = () {
      if (gradientColors.length <= 1) {
        return [0.0, 1.0];
      }
      return List<double>.generate(
        gradientColors.length,
        (i) => i / (gradientColors.length - 1),
      );
    }();


    return Column(
      children: [
        IconButton(
          icon: Icon(isOverviewMode ? Icons.zoom_in : Icons.zoom_out),
          tooltip: isOverviewMode ? 'Detailed View' : 'Overview',
          onPressed: () {
            setState(() {
              this.isOverviewMode = !this.isOverviewMode;
            });
          },
        ),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ GRAPH
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: SizedBox(
                    height: 400,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: SizedBox(
                        width: graphWidth,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              // ซ่อน top & right
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              // แสดง bottom titles
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() < 0 || value.toInt() >= displayDots.length) {
                                       return SizedBox.shrink();
                                    }
                                    
                                    if (isOverviewMode) {
                                      // Overview: ทุกๆ 10 จุด
                                      if (value % 10 == 0) {
                                        // **แก้ไข:** ใช้ค่า X-axis label จาก DotDataPoint
                                        int hour =
                                            displayDots[value.toInt()].x.toInt();
                                        return Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Text('${hour}:00',
                                              style: TextStyle(fontSize: 10)),
                                        );
                                      }
                                    } else {
                                      // Detail: ทุกๆ 500 จุด
                                      if (value % 500 == 0) {
                                        // **แก้ไข:** ใช้ค่า X-axis label จาก DotDataPoint
                                        int hour =
                                            displayDots[value.toInt()].x.toInt();
                                        return Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Text('${hour}:00',
                                              style: TextStyle(fontSize: 8)),
                                        );
                                      }
                                    }
                                    return SizedBox.shrink();
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              // แสดง left titles
                              // **แก้ไข:** ย้าย leftTitles มาไว้ใน FlTitlesData
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                      if (value % 25 == 0) {
                                        return Text(
                                          '${value.toInt()}',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.right,
                                        );
                                      }
                                      return SizedBox.shrink();
                                    },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            minX: 0,
                            maxX: spots.length > 0 ? spots.length.toDouble() -1 : 0, // **แก้ไข:** maxX - 1 ให้ตรงกับ Index
                            minY: 0,
                            maxY: 100,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                // ✅ isCurved ตามโหมด
                                isCurved: isOverviewMode,
                                // **แก้ไข:** LinearGradient 
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  stops: stops,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                barWidth: 2.5,
                                dotData: FlDotData(show: false),
                                shadow: Shadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: Offset(0, 4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ Legend
                const Text('Legend:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // **แก้ไข:** ใช้สีตาม CategoryDetail และ DotDataPoint
                    _buildLegendItem('Apnea', Colors.blue),
                    _buildLegendItem('Quiet', Colors.green),
                    _buildLegendItem('Lound', Colors.orange),
                    _buildLegendItem('Very Lound', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Legend item
  Widget _buildLegendItem(String label, Color color) {
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
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}