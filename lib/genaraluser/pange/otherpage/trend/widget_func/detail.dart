import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/Myfunction/globalFunc/trendgraph.dart';

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

    List<Color> headColor =[Colors.black,Color(0xFF3373A6)];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range
          Row(
            children: [
              // Icon
              detailIcon(Icon(Icons.calendar_today_outlined,size: 30, color: Colors.black)),

              SizedBox(width: 8),
              Text(
                "${metrics.dateRange}",
                style: GoogleFonts.itim(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w600,
                  color: headColor[0]
                ),
              ),
              Text(
                "${metrics.dateRange2}",
                style: GoogleFonts.itim(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w600,
                  color: headColor[1]
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          
          // Session Count
          Row(

            children: [

              detailIcon(Icon(Icons.list,size: 30, color: Colors.black)),
              SizedBox(width: 8),
              Text(
                'Used ${metrics.sessionCount} ',
                style: GoogleFonts.itim(fontSize: 18.5,color: headColor[1],fontWeight: FontWeight.w600,),
              ),
              Text(
                'time${metrics.sessionCount > 1 ? 's' : ''} this ${metrics.preroid}',
                style: GoogleFonts.itim(fontSize: 18.5,color: headColor[0],fontWeight: FontWeight.w600,),
              ),
               
            ],

          ),

          // Change Percentage (if available)
          // if (metrics.changePercent != null) ...[
          SizedBox(height: 12),
          Row(
            children: [
              detailIcon(
                Icon(
                  metrics.changePercent == null
                  ? Icons.close_sharp
                  : metrics.changePercent! > 0 ? Icons.trending_up_rounded :  Icons.trending_down_rounded ,
                  size: 30,
                  color: metrics.changePercent == null
                  ? Colors.blueGrey
                  : metrics.isGood ? Color.fromARGB(255, 84, 192, 87) : Colors.red,
                ),
              ),
              SizedBox(width: 8),
              Text(
                metrics.changePercent != null 
                ? '${metrics.changePercent!.abs().toStringAsFixed(1)}% ${widget.isPercentageType(controller.selectedType) ? 'point ' : ''}${metrics.isGood ? 'improvement' : 'decline'}'
                : "Not specified",
                style: GoogleFonts.itim(
                  fontSize: 18.5,
                  color: metrics.changePercent == null
                  ? Colors.black
                  :metrics.isGood ?  Color.fromARGB(255, 84, 192, 87) : Colors.red,
                  fontWeight: FontWeight.w600,
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


Widget detailIcon(Icon icon) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Color.fromARGB(255, 171, 213, 230),
    ),
    padding: EdgeInsets.all(12), 
    child: icon, 
  ); 
}