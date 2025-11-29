
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/Myfunction/globalFunc/trendgraph.dart';
import 'package:nornsabai/model/reuse_model/bordertype_model.dart';

class PreriodSelector extends StatefulWidget {
  final SleepTrendController controller;

  const PreriodSelector({
    super.key,
    required this.controller
  });

  @override
  State<PreriodSelector> createState() => _PreriodSelectorState();
}

class _PreriodSelectorState extends State<PreriodSelector> {


  @override
  Widget build(BuildContext context) {
    SleepTrendController controller = widget.controller;
    return Column(
      children: [
        _buildPeriodSelector(controller),
      ],
    );
  }
}

// -------------------------------------------------------------------------
// PERIOD SELECTOR
// -------------------------------------------------------------------------

Widget _buildPeriodSelector(SleepTrendController controller) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _periodButton(' Day ', PeriodType.day, controller,BorderRauishorizonyal.left),
      _periodButton(' Week', PeriodType.week, controller,BorderRauishorizonyal.center),
      _periodButton('Month', PeriodType.month, controller,BorderRauishorizonyal.right),
    ],
  );
}

Widget _periodButton(
  String label,
  PeriodType type,
  SleepTrendController controller,
  BorderRauishorizonyal borderRaduis
) {
  List<Color> typetitle = [Colors.black,Color(0xFF3373A6)];
  final isActive = controller.selectedPeriod == type;
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: isActive ? Color.fromARGB(255, 0, 86, 147) : Color.fromARGB(255, 0, 125, 214),
      foregroundColor: isActive ? Colors.white : Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: borderRaduis.border
      ),
      padding: EdgeInsets.symmetric(vertical: 15,horizontal: 30)
    ),
    onPressed: () => controller.selectPeriod(type),
    child: Text(label,style: GoogleFonts.itim(color: Colors.white,fontSize: 27),),
  );
}