import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/graph/trendgraph.dart';

// DETAIL WIDGET
class buildBarDetails extends StatefulWidget {
  final SleepMetrics metrics;
  final SleepTrendController controller;
  final bool Function(DataType) isPercentageType;
  const buildBarDetails({super.key,required this.metrics,required this.controller,required this.isPercentageType});

  @override
  State<buildBarDetails> createState() => buildBarDetailsState();
}

class buildBarDetailsState extends State<buildBarDetails> {
  @override
  Widget build(BuildContext context) {

    SleepMetrics metrics = widget.metrics;
    SleepTrendController controller = widget.controller;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text(
                metrics.dateRange,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          
          // Session Count
          Row(
            children: [
              Icon(Icons.night_shelter, size: 16, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text(
                '${metrics.sessionCount} session${metrics.sessionCount > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),

          // Change Percentage (if available)
          // if (metrics.changePercent != null) ...[
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                metrics.changePercent == null
                ? Icons.close_sharp
                : metrics.changePercent! > 0 ? Icons.arrow_upward :  Icons.arrow_downward ,
                size: 16,
                color: metrics.changePercent == null
                ? Colors.blueGrey
                : metrics.isGood ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                metrics.changePercent != null 
                ? '${metrics.changePercent!.abs().toStringAsFixed(1)}% ${widget.isPercentageType(controller.selectedType) ? 'point ' : ''}${metrics.isGood ? 'improvement' : 'decline'}'
                : "Not specified",
                style: TextStyle(
                  fontSize: 14,
                  color: metrics.changePercent == null
                  ? Colors.black
                  :metrics.isGood ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ],
        // ],
      ),
    );
  }
}