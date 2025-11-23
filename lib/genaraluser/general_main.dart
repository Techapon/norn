import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/My_findaccount.dart';
import 'package:nornsabai/genaraluser/pange/profile_ganeral.dart';
import 'package:nornsabai/genaraluser/pange/record_general.dart';
import 'package:nornsabai/genaraluser/pange/result_ganeral.dart';
import 'package:nornsabai/genaraluser/pange/trend_general.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';


class GeneralMainPage extends StatefulWidget {
  const GeneralMainPage({super.key});

  @override
  State<GeneralMainPage> createState() => _GeneralMainPageState();
}

class _GeneralMainPageState extends State<GeneralMainPage> {
  int _currentIndex = 0; 

  Color navbarcolor = BgColor.BottomNav_bg.color_code;

  String? myDocId;

  bool isLoading = true;

  List<Widget>? pages;

  @override
  void initState() {
    super.initState();
    loadMyDocId();
  }

  Future<void> loadMyDocId() async {
    String myEmail = FirebaseAuth.instance.currentUser!.email!;

    String? docId = await getUserDocIdByEmail("General user",myEmail);

    if (!mounted) return;
    setState(() {
      myDocId = docId;
      isLoading = false;

      pages = [
        RecordGeneral(),
        ResultGaneral(userDocId: myDocId!),   // ได้ค่า docID ที่ถูกต้อง
        TrendGaneral(userDocId: myDocId!,),
        Center(child: Text('search Page')),
        ProfileGeneral(userDocId: myDocId!)
      ];

    });
  }

  List<Widget> getPages() {
    return [
      RecordGeneral(),
      ResultGaneral(userDocId: myDocId!),   // ได้ค่า docID ที่ถูกต้อง
      TrendGaneral(userDocId: myDocId!,),
      Center(child: Text('search Page')),
      ProfileGeneral(userDocId: myDocId!)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: BgColor.Bg1.color_code,
      body: isLoading
      ? Center(
        child: CircularProgressIndicator() 
      )
      : IndexedStack(
        index: _currentIndex,
        children: pages!,
      ),

      bottomNavigationBar: CircleNavBar(
        activeIndex: _currentIndex,
        color: navbarcolor,
        circleWidth: 60,
        height: 90,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // ✅ เมื่อกดไปที่ Result tab → เช็คว่ามี session ใหม่
          // if (index == 1) {
          //   _resultKey.currentState?.checkAndRefresh();
          // }
        },
        
        activeIcons: [
          Icon(Icons.mic, color: Colors.white, size: 37.5),
          Icon(Icons.play_arrow_outlined, color: Colors.white, size: 37.5),
          Icon(Icons.bar_chart, color: Colors.white, size: 37.5),
          Icon(Icons.search_outlined, color: Colors.white, size: 37.5),
          Icon(Icons.account_circle, color: Colors.white, size: 37.5),
        ],
        
        inactiveIcons: [
          Icon(Icons.mic, color: Colors.white.withOpacity(0.26), size: 37.5),
          Icon(Icons.play_arrow_outlined, color: Colors.white.withOpacity(0.26), size: 37.5),
          Icon(Icons.bar_chart, color: Colors.white.withOpacity(0.26), size: 37.5),
          Icon(Icons.search_outlined, color: Colors.white.withOpacity(0.26), size: 37.5),
          Icon(Icons.account_circle, color: Colors.white.withOpacity(0.26), size: 37.5),
        ],

        levels: ["Record", "Result", "Trend", "Discover", "Profile"],
        activeLevelsStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          height: 4.5
        ),

        inactiveLevelsStyle: TextStyle(
          color: Colors.white.withOpacity(0)
        ),
      ),
    );
  }
}



