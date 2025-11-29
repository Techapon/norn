import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math' as math;

// ============================================================================
// SLEEP CONTROLLER - โหลด session หนึ่งครั้งแล้วเก็บ cache
// ============================================================================

class SleepController {
  final String userDocId;

  Map<String, dynamic>? sessionData;
  List<DotDataPoint> allDots = [];
  List<DotDataPoint> overviewDots = [];
  int? _sessionId;

  SleepController({required this.userDocId});

  bool get isLoaded => sessionData != null && allDots.isNotEmpty;

  Future<bool?> loadLatestSession({int? sessionId}) async {
    bool getSesformId;

    if (sessionId != null && _sessionId == sessionId && isLoaded) {
      return null;
    }

    if (sessionId == null && isLoaded) {
      return null;
    }
    try {
      // final user = FirebaseAuth.instance.currentUser;
      // if (user == null) return null;

      // final userEmail = user.email;
      final firestore = FirebaseFirestore.instance;

      DocumentSnapshot<Map<String,dynamic>>? targetSession;

      if (sessionId != null) {
        getSesformId = true;
        final sessionsQuery = await firestore
          .collection('General user')
          .doc(userDocId)
          .collection('sleepsession')
          .where('id', isEqualTo: sessionId)
          .limit(1)
          .get();

        if (sessionsQuery.docs.isEmpty) {
          print('⚠️ Session ID $sessionId not found');
          return null;
        }

        targetSession = sessionsQuery.docs.first;
        print("Loaded session ID: ${sessionId}");
      }else {
        getSesformId = false;
        final sessionsQuery = await firestore
          .collection('General user')
          .doc(userDocId)
          .collection('sleepsession')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

        if (sessionsQuery.docs.isEmpty) return null;

        targetSession = sessionsQuery.docs.first;
        final latestSessionId  = targetSession.get('id') as int;
      }

      final loadedSessionId = targetSession.get('id') as int; 

      if (_sessionId == loadedSessionId && allDots.isNotEmpty) {
        print('ℹ️ Using cached data for session $loadedSessionId');
        return null;
      }

      allDots = await _fetchAllDots(targetSession.reference);
      overviewDots = _createOverviewData(allDots, 60);

      _sessionId = getSesformId ? sessionId : loadedSessionId;
      sessionData = targetSession.data();
      return true;
    } catch (e) {
      print('Error loading latest session: $e');
      return false;
    }
  }

  void clearCache() {
    _sessionId = null;
    sessionData = null;
    allDots = [];
    overviewDots = [];
  }

  // เพิ่ม method สำหรับ force reload
  Future<void> forceReload({int? sessionId}) async {
    clearCache();
    await loadLatestSession(sessionId: sessionId);
  }

  // ========================================================================
  // GET ALL SESSOIN ID
  // ========================================================================
  Future<List<int>> getAllSessionIds() async {
    try {
      // final user = FirebaseAuth.instance.currentUser;
      // if (user == null) return [];

      // final userEmail = user.email;
      final firestore = FirebaseFirestore.instance;

      final sessionsQuery = await firestore
          .collection('General user')
          .doc(userDocId)
          .collection('sleepsession')
          .orderBy('id', descending: true)
          .get();

      return sessionsQuery.docs
          .map((doc) => doc.get('id') as int)
          .toList();
    } catch (e) {
      print('❌ Error getting session IDs: $e');
      return [];
    }
  }

  // ========================================================================
  // GET ALL METDATA
  // ========================================================================
  Future<List<Map<String, dynamic>>> getSleepTimeandId() async {
    try {
      // final user = FirebaseAuth.instance.currentUser;
      // if (user == null) return [];

      // final userEmail = user.email;
      final firestore = FirebaseFirestore.instance;

      final sessionsQuery = await firestore
          .collection('General user')
          .doc(userDocId)
          .collection('sleepsession')
          .orderBy('id', descending: true)
          .get();

      return sessionsQuery.docs.map((doc) {
        final data = doc.data();
        
        final startStamp = parseDateTime( data['startTime']);
        // final endStamp = _parseDateTime( data['endTime']);

        final startDT = DateTime(
          startStamp!.year,
          startStamp.month,
          startStamp.day,
        );
        // final endtDT = DateTime(
        //   endStamp!.year,
        //   endStamp.month,
        //   endStamp.day,
        // );

        return {
          'id': data['id'],
          'startTime':startDT,
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting sessions metadata: $e');
      return [];
    }
  }

  // GET SESSON ID
  int? get currentSessionId => _sessionId;

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

    print("📊 Loaded ${allDots.length} dots from ${hourDocsList.length} hour documents");

    final remainerDoc = await sessionDocRef
        .collection('sleepdetail')
        .doc('remainer')
        .get();

    if (remainerDoc.exists) {
      // ✅ FIXED: Read dot field directly from remainer document
      // This matches the storage format in putsession.dart line 127
      final dots = remainerDoc.get('dot') as List<dynamic>? ?? [];
      
      print("📊 Loading ${dots.length} dots from remainer");
      
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

    print("📊 Total dots loaded: ${allDots.length}");
    
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

  DateTime? parseDateTime(dynamic timeRaw) {
    try {
      if (timeRaw is Timestamp) return timeRaw.toDate();
      if (timeRaw is String) return DateTime.parse(timeRaw);
      return null;
    } catch (_) {
      return null;
    }
  }

  String _formatTime(dynamic timeRaw) {
    final dt = parseDateTime(timeRaw);
    if (dt == null) return '--:--';
    return DateFormat('h:mm a').format(dt);
  }

  // ==========================
  // PUBLIC UTILITY FUNCTIONS
  // ==========================

  List<String> getDateToday() {
    if (!isLoaded) return ['--', '--'];
    final startTime = sessionData!['startTime'];
    final dt = parseDateTime(startTime);
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
    final start = parseDateTime(sessionData!['startTime']);
    final end = parseDateTime(sessionData!['endTime']);
    if (start == null || end == null) return '--:--';
    final duration = end.difference(start);
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
  }

  String _getCategory(double value) {
    if (0 <= value && value <= 25) return "Apnea";
    if (25 < value && value <= 50) return "Quiet";
    if (50 < value && value <= 75) return "Lound";
    if (75 < value && value <= 100) return "Very Lound";
    return "Unknown";
  }


  Map<String, CategoryDetail> getCategoryDetails() {
    if (!isLoaded) return {};
    final apneaCount = sessionData!['apnea'] as int? ?? 0;
    final quietCount = sessionData!['quiet'] as int? ?? 0;
    final loundCount = sessionData!['lound'] as int? ?? 0;
    final veryLoundCount = sessionData!['verylound'] as int? ?? 0;

    final int total = apneaCount+quietCount+loundCount+veryLoundCount;
    final double apneaPercent = (apneaCount / total.toDouble())*100;
    final double quietPercent = (quietCount / total.toDouble())*100;
    final double loundPercent = (loundCount / total.toDouble())*100;
    final double veryLoundPercent = (veryLoundCount / total.toDouble())*100;

    return {
      'apnea': CategoryDetail(
        color: Color(0xFF2283D0),
        count: apneaCount,
        percent: apneaPercent,
        start: 0,
        end: 25,
        name: 'Undertect',
      ),
      'quiet': CategoryDetail(
        color: Color(0xFF15B700),
        count: quietCount,
        percent: quietPercent,
        start: 25,
        end: 50,
        name: 'Quiet',
      ),
      'lound': CategoryDetail(
        color: Color(0xFFE07528),
        count: loundCount,
        percent: loundPercent,
        start: 50,
        end: 75,
        name: 'Lound',
      ),
      'veryLound': CategoryDetail(
        color: Color(0xFFD53739),
        count: veryLoundCount,
        percent: veryLoundPercent,
        start: 75,
        end: 100,
        name: 'Very Lound',
      ),
    };
  }

  SnoreStats getSnoreStatistics() {
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

  // Update note
  Future<bool> updateSessionNote(String newNote) async {
    try {

      newNote = newNote.trim();

      if (!isLoaded || _sessionId == null) {
        print("Session === ${_sessionId}");
        print('No session loaded');
        return false;
      }
      final firestore = FirebaseFirestore.instance;

      final oldNote = sessionData!["note"].toString();

      if (oldNote == newNote) {
        print("no change on new note");
        return true;
      }

      final sessionQuery = await firestore
          .collection('General user')
          .doc(userDocId)
          .collection('sleepsession')
          .where('id', isEqualTo: _sessionId)
          .limit(1)
          .get();
 
      if (sessionQuery.docs.isEmpty) {
        print('Session ID $_sessionId not found');
        return false;
      }

      await sessionQuery.docs.first.reference.update({"note" : newNote});

      sessionData!['note'] = newNote;

      print('Note updated successfully');
      return true;
    } catch (e) {
      print('Error updating note: $e');
      return false;
    }
  }

  String getNote() {
    if (!isLoaded) return '';
    return sessionData!['note'] as String? ?? '';
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
}

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
        return Color(0xFF2283D0);
      case "Quiet":
        return Color(0xFF15B700);
      case "Lound":
        return Color(0xFF1E07528);
      case "Very Lound":
        return Color(0xFFD53739);
      default:
        return Colors.grey;
    }
  }
}

class CategoryDetail {
  final Color color;
  final int count;
  final double percent;
  final int start;
  final int end;
  final String name;

  CategoryDetail({
    required this.color,
    required this.count,
    required this.percent,
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

// // ============================================================================
// // BUILD PIE GRAPH 
// // ============================================================================

// Widget buildPiechart({
//   required Map<String, CategoryDetail> category
// }) {
//   if (category.isEmpty) {
//     return const Padding(
//       padding: EdgeInsets.all(16),
//       child: Text('No data available'),
//     );
//   }

//   return Container(
//     height: 115,
//     decoration: BoxDecoration(
//       // color: Colors.white
//     ),
//     child: PieChart(
//       PieChartData(
//         centerSpaceRadius: 25, // Adjust this value to control the hole size
//         sections: _piechartSections(category: category),
//         sectionsSpace: 0, // Optional: space between sections
//         startDegreeOffset: -360
//       )
//     ),
//   );
// }

// List<PieChartSectionData> _piechartSections({
//   required Map<String, CategoryDetail> category
// }) {
//   const double radius = 30; // Optional: customize the thickness of the segments

//   final List<CategoryDetail> categoryList = category.values.toList();

//   final List<PieChartSectionData> list = [];

//   for (var item in categoryList) {
//     list.add(
//       PieChartSectionData(
//         color: item.color,
//         value: item.count.toDouble(),
//         title: "",
//         radius: radius,
//         showTitle: true,
//         titleStyle: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
            
//         ),
//       ),
//     );
//   }
//   return list;
// }

// // ============================================================================
// // BUILD PECENT CATEGORY BAR
// // ============================================================================


// buildGategoryBar({
//   required Map<String, CategoryDetail> category
// }) {
//   if (category.isEmpty) {
//     return const Padding(
//       padding: EdgeInsets.all(16),
//       child: Text('No data available'),
//     );
//   }


//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceAround,
//     children: [
//       GatagoryListItem(
//         color: category["apnea"]!.color,
//         title:  category["apnea"]!.name,
//         percent: category["apnea"]!.percent,
//       ),
//       GatagoryListItem(
//         color: category["quiet"]!.color,
//         title:  category["quiet"]!.name,
//         percent: category["quiet"]!.percent,
//       ),
//       GatagoryListItem(
//         color: category["lound"]!.color,
//         title:  category["lound"]!.name,
//         percent: category["lound"]!.percent,
//       ),
//       GatagoryListItem(
//         color: category["veryLound"]!.color,
//         title:  category["veryLound"]!.name,
//         percent: category["veryLound"]!.percent,
//       ),
//     ],
//   );
// }

// Widget GatagoryListItem({
//   required Color color,
//   required String title,
//   required double percent
// }) {
//   return Container(
//     child: Row(
//       children: [
//         Container(
//           height: 35,
//           width: 12,
//           decoration: BoxDecoration(
//             color: color,
//             border: Border.all(color:Colors.black,)
//           ),
//         ),
//         SizedBox(width: 3,),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,style: GoogleFonts.itim(fontSize: 12,color: color),),
//             Text("${percent.toStringAsFixed(2)}%",style: GoogleFonts.itim(fontSize: 12,color: color),)
//           ],
//         )
//       ],
//     ),
//   );
// }

// // ============================================================================
// // BUILD SHOW TIME ITEM
// // ============================================================================

// Widget buildStartEnd({
//   required Map<String, String> startend,
//   required IconData icon
// }) {
//   if (startend.isEmpty || !startend.containsKey("startSession") || !startend.containsKey("endSession")) {
//     return const Padding(
//       padding: EdgeInsets.all(16),
//       child: Text('No data available'),
//     );
//   }

//   String title = "Start/Stop";
//   String desscip = "${startend["startSession"]} to ${startend["endSession"]}";

//   return showtimeItem(
//     title: title,
//     desscrip: desscip,
//     icon: icon
//   );
// }

// Widget buildSleepTime({
//   required String sleeptime,
//   required IconData icon
// }) {
//   if (sleeptime.isEmpty) {
//     return const Padding(
//       padding: EdgeInsets.all(16),
//       child: Text('No data available'),
//     );
//   }

//   String title = "Sleep time";
//   String desscip = "${sleeptime} hours";


//   return showtimeItem(
//     title: title,
//     desscrip: desscip,
//     icon: icon
//   );
// }

// Widget buildSoreDetial({
//   required SnoreStats snoredetial,
//   required IconData icon
// }) {
//   String title = "Snoring time";
//   String desscip = "${snoredetial.totalSnoreTime} hours - ${snoredetial.snorePercentage}%";

//   return showtimeItem(
//     title: title,
//     desscrip: desscip,
//     icon: icon
//   );

// }


// Widget showtimeItem({
//   required String title,
//   required String desscrip,
//   required IconData icon
// }) {
//   return Row(
//     children: [
//       CircleAvatar(
//         radius: 28, 
//         backgroundColor: Colors.blue[200], 
//         child: Icon(icon,color: Colors.black,size: 32,), 
//       ),
//       SizedBox(width: 7.5,),
//       Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,style: GoogleFonts.itim(fontSize: 14.5,color: Colors.blue, fontWeight: FontWeight.w500),),
//           Text(desscrip,style: GoogleFonts.itim(fontSize: 13.5,color:  Colors.blue, fontWeight: FontWeight.w500),)
//         ],
//       )
//     ],
//   );
// }

// // ============================================================================
// // BUILD GRAPH WIDGET
// // ============================================================================

// Widget buildGraphWidget({
//   required BuildContext context,
//   required List<DotDataPoint> dots,
//   required Map<String, dynamic> sessionData,
//   required String docId,
// }) {
//   if (dots.isEmpty) {
//     return const Padding(
//       padding: EdgeInsets.all(16),
//       child: Text('No data available'),
//     );
//   }

//   final mediaWidth = MediaQuery.of(context).size.width;

//   final controller = SleepController(userDocId: docId);
//   final startTimeRaw = sessionData['startTime'];
//   final endTimeRaw = sessionData['endTime'];
//   final startDateTime = controller._parseDateTime(startTimeRaw);
//   final endDateTime = controller._parseDateTime(endTimeRaw);

//   int numBottomTitles = 1;
//   if (startDateTime != null && endDateTime != null) {
//     final totalMinutes = endDateTime.difference(startDateTime).inMinutes;
//     numBottomTitles = (totalMinutes / 30).ceil() + 1;
//   }

//   double minGraphWidth = math.max(mediaWidth - 32, 320);
//   double graphWidth;

//   if (numBottomTitles < 6) {
//     graphWidth = minGraphWidth;
//   } else {
//     graphWidth = math.max(minGraphWidth, numBottomTitles * 60.0);
//   }

//   return Padding(
//     padding: const EdgeInsets.only(left: 16,right: 25),
//     child: SingleChildScrollView(
//       clipBehavior: Clip.none,
//       scrollDirection: Axis.horizontal,
//       physics: const BouncingScrollPhysics(),
//       child: SizedBox(
//         width: graphWidth,
//         height: 275,
//         child: LineChart(
//           _buildChartData(
//             dots: dots,
//             sessionData: sessionData,
//             docId: docId,
//             isCurved: false,
//           ),
//         ),
//       ),
//     ),
//   );
// }

// // ============================================================================
// // BUILD CHART DATA
// // ============================================================================

// LineChartData _buildChartData({
//   required List<DotDataPoint> dots,
//   required Map<String, dynamic> sessionData,
//   required String docId,
//   bool isCurved = false,
// }) {
//   final controller = SleepController(userDocId: docId);
//   final startTimeRaw = sessionData['startTime'];
//   final endTimeRaw = sessionData['endTime'];
//   final startDateTime = controller._parseDateTime(startTimeRaw);
//   final endDateTime = controller._parseDateTime(endTimeRaw);

//   if (startDateTime == null || endDateTime == null || dots.isEmpty) {
//     return LineChartData(
//       minX: 0,
//       maxX: 1,
//       minY: 0,
//       maxY: 100,
//       lineBarsData: [
//         LineChartBarData(spots: [const FlSpot(0, 50)])
//       ],
//     );
//   }

//   final totalMinutes = endDateTime.difference(startDateTime).inMinutes;

//   final List<FlSpot> spots = [];
//   if (dots.isNotEmpty) {
//     for (int i = 0; i < dots.length; i++) {
//       final fraction = (dots.length > 1) ? i / (dots.length - 1) : 0.0;
//       final xPos = fraction * totalMinutes;
//       spots.add(FlSpot(xPos, dots[i].y));
//     }
//   }

//   final Map<double, String> labelPositions = {};
//   for (int min = 0; min <= totalMinutes; min += 30) {
//     final labelTime = startDateTime.add(Duration(minutes: min));
//     final label = DateFormat('H:mm').format(labelTime);
//     labelPositions[min.toDouble()] = label;
//   }
  
//   final endTimeLabel = DateFormat('H:mm').format(endDateTime);
//   labelPositions[totalMinutes.toDouble()] = endTimeLabel;

//   final List<Color> gradientColors = getcategoryColorList();

//   return LineChartData(
//     gridData: FlGridData(
//       show: true,
//       drawHorizontalLine: true,
//       horizontalInterval: 25,
//       getDrawingHorizontalLine: (value) {
//         return FlLine(
//           color: Colors.black.withOpacity(0.2),
//           strokeWidth: 1,
//           dashArray: [5],
//         );
//       },
//       getDrawingVerticalLine: (value) {
//         return FlLine(
//           strokeWidth: 0,
//         );
//       },
//     ),
//     titlesData: FlTitlesData(
//       topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 32,
//           interval: 30,
//           getTitlesWidget: (value, meta) {
//             if (labelPositions.containsKey(value)) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   labelPositions[value]!,
//                   style: GoogleFonts.itim(fontSize: 12, fontWeight: FontWeight.w500),
//                 ),
//               );
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 30,
//           interval: 25,
//           getTitlesWidget: (value, meta) {
//             return Text(
//               value.toInt().toString(),
//               style: GoogleFonts.itim(fontSize: 12,fontWeight: FontWeight.w500),
//               textAlign: TextAlign.center,
//             );
//           },
//         ),
//       ),
//     ),
//     borderData: FlBorderData(
//       show: true,
//       border: Border(
//         left: BorderSide(color: Colors.black),
//         bottom: BorderSide(color: Colors.black),
//         top: BorderSide.none,
//         right: BorderSide.none,
//       ),
//     ),
//     minX: 0,
//     maxX: totalMinutes.toDouble(),
//     minY: 0,
//     maxY: 100,
//     lineBarsData: [
//       LineChartBarData(
//         spots: spots,
//         isCurved: isCurved,
//         gradient: LinearGradient(
//           colors: gradientColors,
//           begin: Alignment.bottomCenter,
//           end: Alignment.topCenter,
//         ),
//         barWidth: 2.5,
//         dotData: FlDotData(show: false),
//         shadow: Shadow(
//           blurRadius: 8,
//           color: Colors.black.withOpacity(0.1),
//           offset: const Offset(0, 4),
//         ),
//       ),
//     ],
//     lineTouchData: LineTouchData(
//       enabled: true,
//       touchTooltipData: LineTouchTooltipData(
//         getTooltipItems: (touchedSpots) {
//           return touchedSpots.map((spot) {
//             int closestIndex = 0;
//             double minDist = double.infinity;
//             for (int i = 0; i < spots.length; i++) {
//               final dist = (spots[i].x - spot.x).abs();
//               if (dist < minDist) {
//                 minDist = dist;
//                 closestIndex = i;
//               }
//             }

//             String timeLabel = '--:--';
//             final minutesOffset = spots[closestIndex].x.toInt();
//             final labelTime =
//                 startDateTime.add(Duration(minutes: minutesOffset));
//             timeLabel = DateFormat('H:mm').format(labelTime);

//             return LineTooltipItem(
//               'at $timeLabel : ${spot.y.toStringAsFixed(1)} lound',
//               const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             );
//           }).toList();
//         },
//         getTooltipColor: (LineBarSpot touchedSpot) {
//           return colorCal(touchedSpot.y);
//         },
//         tooltipBorderRadius: BorderRadius.circular(8),
//       ),
//       getTouchLineStart: (barData, spotIndex) => 0,
//       getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
//         return spotIndexes.map((index) {
//           return TouchedSpotIndicatorData(
//             FlLine(
//               color: colorCal(barData.spots[index].y),
//               strokeWidth: 2,
//               dashArray: [4, 4],
//             ),
//             FlDotData(
//               show: true,
//               getDotPainter: (spot, percent, barData, index) {
//                 return FlDotCirclePainter(
//                   radius: 4,
//                   color: colorCal(spot.y),
//                   strokeWidth: 1,
//                   strokeColor: Colors.white,
//                 );
//               },
//             ),
//           );
//         }).toList();
//       },
//     ),
//   );
// }

// // ============================================================================
// // LEGEND
// // ============================================================================

// Widget _buildLegendSection() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text(
//         'Legend',
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       const SizedBox(height: 8),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: const [
//           _LegendItem(label: 'Apnea', color: Colors.blue),
//           _LegendItem(label: 'Quiet', color: Colors.green),
//           _LegendItem(label: 'Lound', color: Colors.orange),
//           _LegendItem(label: 'Very Lound', color: Colors.red),
//         ],
//       ),
//     ],
//   );
// }

// class _LegendItem extends StatelessWidget {
//   final String label;
//   final Color color;

//   const _LegendItem({required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }

