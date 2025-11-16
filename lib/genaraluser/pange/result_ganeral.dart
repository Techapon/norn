import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/graph/dailygraph.dart';
import 'package:google_fonts/google_fonts.dart';


class ResultGaneral extends StatefulWidget {
  const ResultGaneral({super.key});

  @override
  State<ResultGaneral> createState() => _ResultGaneralState();
}

class _ResultGaneralState extends State<ResultGaneral> {

  // DateTime now = DateTime.now();
  late Future<Map<String, dynamic>> futureGraphData;

  // overview?
  bool isOverviewMode = true;

  List<Color> datecolor = [ Color(0xFF000000),Color(0xFF3373A6)];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  // // ✅ ใช้ Function 1
  // FutureBuilder<String>(
  //   future: getDateToday(),
  //   builder: (context, snapshot) {
  //     if (!snapshot.hasData) return SizedBox.shrink();
  //     return Text(snapshot.data ?? '');
  //   },
  // ),
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("444"),
          GraphBuilder(),
        ],
      ),
    );
  }
}
