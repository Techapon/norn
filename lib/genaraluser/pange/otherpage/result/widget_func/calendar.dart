import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/checkapnea.dart';

// void CalanderDialog({
//     required BuildContext context,
// }) {
//     DateTime _focusedDay = DateTime.now();
//     DateTime? _selectedDay;
  
    
// }

// class CalanderDialog extends StatefulWidget {
  
//   CalanderDialog({super.key,});

//   @override
//   State<CalanderDialog> createState() => _CalanderDialogState();
// }

// class _CalanderDialogState extends State<CalanderDialog> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   @override
//   Widget build(BuildContext context) {
    
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(4),
//       ),
//       insetPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 65),
//       child: Container(
//         width: double.maxFinite,
//         clipBehavior: Clip.antiAlias,
//         padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.white,
//         ),
//         child: Column(
//           children: [
            
//             // Calendar
//             HeatMap(
//               datasets: {
                
//               },
             
//               showColorTip: false,

//               startDate: DateTime.now(),
//               endDate:  DateTime.now().add(Duration(days: 60)),
              
//               textColor: Colors.grey[600],
//               size: 35,
//               colorMode: ColorMode.opacity,
//               showText: true,
//               scrollable: true,
//               colorsets: {
//                 1: Colors.blue,
                
//               },
//               onClick: (value) {
//                 print("${value}");
                
//               },
//             ),

            
//           ],
//         ),
//       ),
//     );
//   }
// }

