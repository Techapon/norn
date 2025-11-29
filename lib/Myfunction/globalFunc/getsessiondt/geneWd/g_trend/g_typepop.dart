
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/Myfunction/globalFunc/trendgraph.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

class SleepdataSelector extends StatefulWidget {
  final SleepTrendController controller;

  const SleepdataSelector({
    super.key,
    required this.controller
  });

  @override
  State<SleepdataSelector> createState() => _SleepdataSelectorState();
}

class _SleepdataSelectorState extends State<SleepdataSelector> {
  List<String> textLabel = ["Snore","Score"];
  List<Color> typetitle = [Colors.black,Color(0xFF3373A6)];

  @override
  Widget build(BuildContext context) {
    SleepTrendController controller = widget.controller;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Color(0xFF90BCCD),
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12)
          )
        ),
        padding: EdgeInsets.symmetric(horizontal: 22,vertical: 5)
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 25,vertical: 150),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)
                ),
                padding: EdgeInsets.symmetric(vertical: 20),
                child: _buildDataTypeSelector(controller),
              )
            );
          }
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${textLabel[0]}",style: GoogleFonts.itim(color: typetitle[0], fontSize: 23,fontWeight: FontWeight.bold),),
          Text("${textLabel[1]}",style: GoogleFonts.itim(color: typetitle[1], fontSize: 23,fontWeight: FontWeight.bold),),
          SizedBox(width: 7.5,),
          Icon(Icons.open_in_new_rounded,color: Colors.black,size: 30,),
        ],
      ),
    );
  }

   // -------------------------------------------------------------------------
  // DA-TA TYPE SELECTOR
  // -------------------------------------------------------------------------
  Widget _buildDataTypeSelector(SleepTrendController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 30,vertical: 10),
            child: Text("Snore",style:  GoogleFonts.itim(color: Colors.black,fontSize: 30),),
          ),
          _typeButton('Snore Score', DataType.snoreScore, controller),
          _typeButton('Snore %', DataType.snorePercent, controller),
          _typeButton('Loud %', DataType.loudPercent, controller),
          _typeButton('Very Loud %', DataType.veryLoudPercent, controller),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 30,vertical: 10),
            child: Text("Undetected",style:  GoogleFonts.itim(color: Colors.black,fontSize: 30),),
          ),
          _typeButton('Undetected', DataType.undetected, controller),
          _typeButton('Undetected %', DataType.undetectedPercent, controller),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 30,vertical: 10),
            child: Text("Quiet",style:  GoogleFonts.itim(color: Colors.black,fontSize: 30),),
          ),
          _typeButton('Quiet', DataType.quiet, controller),
          _typeButton('Quiet %', DataType.quietPercent, controller),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 30,vertical: 10),
            child: Text("Sleep",style:  GoogleFonts.itim(color: Colors.black,fontSize: 30),),
          ),
          _typeButton('Sleep Time', DataType.sleepTime, controller),

          SizedBox(height: 30,)
        ],
      ),
    );
  }

  Widget _typeButton(
    String label,
    DataType type,
    SleepTrendController controller,
  ) {
    final isActive = controller.selectedType == type;
    bool isPressed = false;
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 7.5,vertical: 0),
              foregroundColor: Colors.grey,
              backgroundColor: isActive ? Colors.grey[200] : Colors.transparent,
              side: BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero
              ),
            ),
            onPressed: () {
              setState(() {
                controller.selectDataType(type);
                Navigator.of(context).pop();
                textLabel = getTypeLable(datalabel: label);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14,horizontal: 35),
              color: Colors.transparent,
              child: Text("${label} ${isActive ? '(Selected)' : '' }",style:  GoogleFonts.itim(color: Colors.black.withOpacity(0.9),fontSize: 19.5),),
            ),
          ),
        ),
      ],
    );
  }
}


List<String> getTypeLable({required String datalabel}) {
  List<String> textlabel = [];
  switch (datalabel) {
    case "Snore Score":
      textlabel.add("Snore ");
      textlabel.add("Score");
      break;
    case "Snore %":
      textlabel.add("Snore ");
      textlabel.add("%");
      break;
    case "Loud %":
      textlabel.add("Loud ");
      textlabel.add("%");
      break;
    case "Very Loud %":
      textlabel.add("Very Loud ");
      textlabel.add("%");
      break;
    case "Undetected":
      textlabel.add("Unde");
      textlabel.add("tected");
      break;
    case "Undetected %":
      textlabel.add("Undetected ");
      textlabel.add("%");
      break;
    case "Quiet":
      textlabel.add("Qu");
      textlabel.add("iet");
      break;
    case "Quiet %":
      textlabel.add("Quiet ");
      textlabel.add("%");
      break;
    case "Sleep Time":
      textlabel.add("Sleep ");
      textlabel.add("Time");
      break;
  }
  return textlabel;
}