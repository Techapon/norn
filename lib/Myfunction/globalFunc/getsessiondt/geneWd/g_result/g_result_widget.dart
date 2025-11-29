import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:nornsabai/Myfunction/globalFunc/dailygraph.dart';

// ============================================================================
// BUILD PIE GRAPH 
// ============================================================================

Widget buildPiechart({
  required Map<String, CategoryDetail> category
}) {
  if (category.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('No data available'),
    );
  }

  return Container(
    height: 200,
    decoration: BoxDecoration(
      // color: Colors.white
    ),
    child: PieChart(
      PieChartData(
        centerSpaceRadius: 35, // Adjust this value to control the hole size
        sections: _piechartSections(category: category),
        sectionsSpace: 0, // Optional: space between sections
        startDegreeOffset: -360
      )
    ),
  );
}

List<PieChartSectionData> _piechartSections({
  required Map<String, CategoryDetail> category
}) {
  const double radius = 55; // Optional: customize the thickness of the segments

  final List<CategoryDetail> categoryList = category.values.toList();

  final List<PieChartSectionData> list = [];

  for (var item in categoryList) {
    list.add(
      PieChartSectionData(
        color: item.color,
        value: item.count.toDouble(),
        title: "",
        radius: radius,
        showTitle: true,
        titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            
        ),
      ),
    );
  }
  return list;
}

// ============================================================================
// BUILD PECENT CATEGORY BAR
// ============================================================================


buildGategoryBar({
  required Map<String, CategoryDetail> category
}) {
  if (category.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('No data available'),
    );
  }


  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      GatagoryListItem(
        color: category["apnea"]!.color,
        title:  category["apnea"]!.name,
        percent: category["apnea"]!.percent,
      ),
      GatagoryListItem(
        color: category["quiet"]!.color,
        title:  category["quiet"]!.name,
        percent: category["quiet"]!.percent,
      ),
      GatagoryListItem(
        color: category["lound"]!.color,
        title:  category["lound"]!.name,
        percent: category["lound"]!.percent,
      ),
      GatagoryListItem(
        color: category["veryLound"]!.color,
        title:  category["veryLound"]!.name,
        percent: category["veryLound"]!.percent,
      ),
    ],
  );
}

Widget GatagoryListItem({
  required Color color,
  required String title,
  required double percent
}) {
  return Container(
    child: Row(
      children: [
        Container(
          height: 50,
          width: 20,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color:Colors.black,)
          ),
        ),
        SizedBox(width: 3,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,style: GoogleFonts.itim(fontSize: 15,color: color),),
            Text("${percent.toStringAsFixed(2)}%",style: GoogleFonts.itim(fontSize: 17.5,color: color),)
          ],
        )
      ],
    ),
  );
}

// ============================================================================
// BUILD SHOW TIME ITEM
// ============================================================================

Widget buildStartEnd({
  required Map<String, String> startend,
  required IconData icon
}) {
  if (startend.isEmpty || !startend.containsKey("startSession") || !startend.containsKey("endSession")) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('No data available'),
    );
  }

  String title = "Start/Stop";
  String desscip = "${startend["startSession"]} to ${startend["endSession"]}";

  return showtimeItem(
    title: title,
    desscrip: desscip,
    icon: icon
  );
}

Widget buildSleepTime({
  required String sleeptime,
  required IconData icon
}) {
  if (sleeptime.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('No data available'),
    );
  }

  String title = "Sleep time";
  String desscip = "${sleeptime} hours";


  return showtimeItem(
    title: title,
    desscrip: desscip,
    icon: icon
  );
}

Widget buildSoreDetial({
  required SnoreStats snoredetial,
  required IconData icon
}) {
  String title = "Snoring time";
  String desscip = "${snoredetial.totalSnoreTime} hours - ${snoredetial.snorePercentage}%";

  return showtimeItem(
    title: title,
    desscrip: desscip,
    icon: icon
  );

}


Widget showtimeItem({
  required String title,
  required String desscrip,
  required IconData icon
}) {
  return Row(
    children: [
      CircleAvatar(
        radius: 55, 
        backgroundColor: Colors.blue[200], 
        child: Icon(icon,color: Colors.black,size: 40,), 
      ),
      SizedBox(width: 7.5,),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: GoogleFonts.itim(fontSize: 20,color: Colors.blue, fontWeight: FontWeight.w500),),
          Text(desscrip,style: GoogleFonts.itim(fontSize: 17.5,color:  Colors.blue, fontWeight: FontWeight.w500),)
        ],
      )
    ],
  );
}

// ============================================================================
// BUILD GRAPH WIDGET
// ============================================================================

Widget buildGraphWidget({
  required BuildContext context,
  required List<DotDataPoint> dots,
  required Map<String, dynamic> sessionData,
  required String docId,
}) {
  if (dots.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('No data available'),
    );
  }

  final mediaWidth = MediaQuery.of(context).size.width;

  final controller = SleepController(userDocId: docId);
  final startTimeRaw = sessionData['startTime'];
  final endTimeRaw = sessionData['endTime'];
  final startDateTime = controller.parseDateTime(startTimeRaw);
  final endDateTime = controller.parseDateTime(endTimeRaw);

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
    graphWidth = math.max(minGraphWidth, numBottomTitles * 125.0);
  }

  return Padding(
    padding: const EdgeInsets.only(left: 16,right: 25),
    child: SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: graphWidth,
        height: 450,
        child: LineChart(
          _buildChartData(
            dots: dots,
            sessionData: sessionData,
            docId: docId,
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
  required String docId,
  bool isCurved = false,
}) {
  final controller = SleepController(userDocId: docId);
  final startTimeRaw = sessionData['startTime'];
  final endTimeRaw = sessionData['endTime'];
  final startDateTime = controller.parseDateTime(startTimeRaw);
  final endDateTime = controller.parseDateTime(endTimeRaw);

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
                  style: GoogleFonts.itim(fontSize: 17.5, fontWeight: FontWeight.w500),
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
              style: GoogleFonts.itim(fontSize: 17.5,fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            );
          },
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border(
        left: BorderSide(color: Colors.black),
        bottom: BorderSide(color: Colors.black),
        top: BorderSide.none,
        right: BorderSide.none,
      ),
    ),
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
