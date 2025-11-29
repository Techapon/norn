import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/My_findaccount.dart';
import 'package:nornsabai/genaraluser/pange/discover_general.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/record/func/latestsession.dart';
import 'package:nornsabai/genaraluser/pange/profile_ganeral.dart';
import 'package:nornsabai/genaraluser/pange/record_general.dart';
import 'package:nornsabai/genaraluser/pange/result_ganeral.dart';
import 'package:nornsabai/genaraluser/pange/trend_general.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';
import 'package:nornsabai/Myfunction/globalFunc/alarmsystem/function/alarm_func.dart';


// update
late UserStatusService updatebreath;

class GeneralMainPage extends StatefulWidget {
  const GeneralMainPage({super.key});
  
  @override
  State<GeneralMainPage> createState() => _GeneralMainPageState();
}



class _GeneralMainPageState extends State<GeneralMainPage> {
  int _currentIndex = 0; 

  Color navbarcolor = BgColor.BottomNav_bg.color_code;

  String? myDocId;
  LatestSessionData? latestSessionData;

  bool isLoading = true;

  List<Widget>? pages;

  @override
  void initState() {
    super.initState();

    pages = [
      RecordGeneral(latestSessionData: null, setcurrent: null),
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
    ];

    loadMyDocId();
  }

  Future<void> loadMyDocId() async {
    String myEmail = FirebaseAuth.instance.currentUser!.email!;

    String? docId = await getUserDocIdByEmail("General user",myEmail);

    // ตั้งค่า updatebreath
    updatebreath = UserStatusService(docId: docId!);

    latestSessionData = await getLatestSessionByUserId(docId!);
    
    if (!mounted) return;
    setState(() {
      myDocId = docId;
      isLoading = false;

      pages = [
        RecordGeneral(latestSessionData: latestSessionData,setcurrent: (id) { setcurrent(id); } ),
        ResultGaneral(userDocId: myDocId!),   
        TrendGaneral(userDocId: myDocId!,),
        DiscoverGeneral(),
        ProfileGeneral(userDocId: myDocId!)
      ];

    });
  }

  List<Widget> getPages() {
    return [
      RecordGeneral(latestSessionData: latestSessionData,setcurrent: (id) { setcurrent(id); } ),
      ResultGaneral(userDocId: myDocId!),  
      TrendGaneral(userDocId: myDocId!,),
      DiscoverGeneral(),
      ProfileGeneral(userDocId: myDocId!)
    ];
  }

  void setcurrent(int id) {
    setState(() {
      _currentIndex = id;
    });
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
        circleWidth: 80,
        height: 130,

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
          Icon(Icons.mic, color: Colors.white, size: 45),
          Icon(Icons.play_arrow_outlined, color: Colors.white, size: 45),
          Icon(Icons.bar_chart, color: Colors.white, size: 45),
          Icon(Icons.search_outlined, color: Colors.white, size: 45),
          Icon(Icons.account_circle, color: Colors.white, size: 45),
        ],
        
        inactiveIcons: [
          Icon(Icons.mic, color: Colors.white.withOpacity(0.26), size: 50),
          Icon(Icons.play_arrow_outlined, color: Colors.white.withOpacity(0.26), size: 50),
          Icon(Icons.bar_chart, color: Colors.white.withOpacity(0.26), size: 50),
          Icon(Icons.search_outlined, color: Colors.white.withOpacity(0.26), size: 50),
          Icon(Icons.account_circle, color: Colors.white.withOpacity(0.26), size: 50),
        ],

        levels: ["Record", "Result", "Trend", "Discover", "Profile"],
        activeLevelsStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          height: 4.0
        ),

        inactiveLevelsStyle: TextStyle(
          color: Colors.white.withOpacity(0)
        ),
      ),
    );
  }
}



