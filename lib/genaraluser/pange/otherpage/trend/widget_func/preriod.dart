
import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/graph/trendgraph.dart';

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

        SizedBox(height: 30),
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
      _periodButton('Day', PeriodType.day, controller),
      _periodButton('Week', PeriodType.week, controller),
      _periodButton('Month', PeriodType.month, controller),
    ],
  );
}

Widget _periodButton(
  String label,
  PeriodType type,
  SleepTrendController controller,
) {
  final isActive = controller.selectedPeriod == type;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.black87,
      ),
      onPressed: () => controller.selectPeriod(type),
      child: Text(label),
    ),
  );
}