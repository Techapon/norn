
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/Myfunction/globalFunc/dailygraph.dart';

// form care result
import 'package:nornsabai/Myfunction/globalFunc/getsessiondt/careWd/c_result/c_result_widget.dart';

import 'package:nornsabai/model/data_model/requestmodel.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

class Resultuser extends StatefulWidget {
  FriendRequestWithUserData generaldata;

  Resultuser({required this.generaldata});

  @override
  State<Resultuser> createState() => ResultuserState();
}

class ResultuserState extends State<Resultuser> {

  late SleepController controller;

  late FriendRequestWithUserData generaldata;
  late String generalId;

  bool _isLoading = true;
  String? _errorMessage;

  // color
  List<Color> headColor =[Colors.black,Color(0xFF3373A6)];

  // other sesion detial
  Map<String, CategoryDetail>? _categortList;
  List<String>? _dateToday;
  Map<String, String>? _startend;
  String? _sleeptime;
  SnoreStats? _snoredetial;
  String? _note;
  List<Map<String, dynamic>> allsleepsession =[];

  // loading
  bool addnoteLoading = false;

  @override
  void initState() {
    super.initState();
    generaldata = widget.generaldata;
    generalId = generaldata.targetUser!.userId;
    controller = SleepController(userDocId: generalId);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      
      await controller.loadLatestSession();
      _categortList = controller.getCategoryDetails();
      _dateToday = controller.getDateToday();
      _startend = controller.getSleepStartEnd();
      _sleeptime = controller.getTotalSleepTime();
      _snoredetial = controller.getSnoreStatistics();
      _note = controller.getNote();
      
      allsleepsession = await controller.getSleepTimeandId();
      
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ✅ Refresh function สำหรับ RefreshIndicator
  Future<void> _onRefresh() async {
    try {
      // บังคับให้โหลดข้อมูลใหม่
      controller.clearCache();
      await controller.loadLatestSession();

      _categortList = controller.getCategoryDetails();
      _dateToday = controller.getDateToday();
      _startend = controller.getSleepStartEnd();
      _sleeptime = controller.getTotalSleepTime();
      _snoredetial = controller.getSnoreStatistics();
      _note = controller.getNote();

      allsleepsession = await controller.getSleepTimeandId();
      print(allsleepsession);
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error refreshing: $e');
    }
  }


  void notedialog({
    required BuildContext context,
    required String DatabaseNote
  }) {


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          insetPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 20),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: BgColor.Bg1.color_code,
                borderRadius: BorderRadius.circular(6),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                          
                  Container(
                    decoration: BoxDecoration(
                      color: BgColor.Bg1_dark.color_code,
                      border: Border(
                        bottom: BorderSide(width: 1,color: Colors.black)
                      )
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Title",style:  GoogleFonts.itim(fontSize: 25),),
                      ],
                    ),
                  ),
                          
                  // content
                  Container(
                    decoration: BoxDecoration(
                      color: BgColor.Bg1.color_code
                    ),
                    height: 400,
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 35,horizontal: 30),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          DatabaseNote,
                          style: GoogleFonts.itim(fontSize: 20,color: Color.fromARGB(255, 81, 128, 152),fontWeight: FontWeight.w500),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ),
                ],
                          
              ),
            ),
          ),
        );
      }
    );
  }

  // Calendar
  void showCalendar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        // check datetime
        Map<String,dynamic> findIdByExactDateTime(List<Map<String, dynamic>> sessions, DateTime inputDate) {          
          for (var session in sessions) {
            DateTime sessionDate = session['startTime'];
            print(sessionDate);
            
            // เทียบแบบ exact
            if (sessionDate.isAtSameMomentAs(inputDate)) {
              print('✅ Found! ID: ${session['id']}');
              return {
                "result" : true,
                "id" : session['id']
              }; 
            }
          }
          return {
            "result" : false,
            "id" : null
          };
        }

        List<DateTime> dataTimeList = allsleepsession.map((data) => data["startTime"] as DateTime).toList();

        DateTime startCalen = dataTimeList.last;
        DateTime endCalen = dataTimeList.first;

        Map<DateTime, int> datasetsDate = {
          for (var date in dataTimeList) date: 1
        };
        
        return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 65),
        child: Container(
          width: double.maxFinite,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              
              // head
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Choose Sleep",
                      style: GoogleFonts.itim(fontSize: 25,color: headColor[0]),
                    ),
                    SizedBox(width: 5,),
                    Text(
                      "Sessions",
                      style: GoogleFonts.itim(fontSize: 25,color: headColor[1]),
                    ),
                    // SizedBox(width: 5,),
                  ],
                ),
              ),

              // Calendar
              Container(
                child: HeatMap(
                  datasets: datasetsDate,
                  showColorTip: false,
                
                  startDate: DateTime(startCalen.year,startCalen.month,1),
                  endDate: DateTime(endCalen.year,endCalen.month+1,0),
                  
                  textColor: Colors.grey[600],
                  defaultColor: Colors.grey[360],
                  
                  
                  size: 35,
                  colorMode: ColorMode.opacity,
                  showText: true,
                  scrollable: true,
                  colorsets: {
                    1: const Color.fromARGB(255, 110, 190, 255),
                    
                  },
                  onClick: (value) async{
                    final dateClick = DateTime(
                      value.year,
                      value.month,
                      value.day,
                    );
                    print("${dateClick}");
                    Map<String,dynamic> dataResult =  findIdByExactDateTime(allsleepsession,dateClick);
                    if (dataResult["result"]) {
                      MyDiaologAlertFuture(
                        context: context,
                        yesText: "Yes,I do",
                        cancelText: "cancle",
                        mainText: "Choose sleep session",
                        whenSuccess: "Session data loaded!!",
                        whenFail: "Something went wrong,Please try again",
                        desscrip: "Do you want to choose sleep session?",
                        onpressed: () async{
                          await controller.loadLatestSession(sessionId: dataResult["id"]);
                          _dateToday = controller.getDateToday();
                          _startend = controller.getSleepStartEnd();
                          _sleeptime = controller.getTotalSleepTime();
                          _snoredetial = controller.getSnoreStatistics();
                          _note = controller.getNote();
                
                          if (mounted) {
                            setState(() {});
                          }
                          return true;
                        },
                      );
                     
                    }
                  },
                
                  
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 15),
                child: Text("*Select your sleep session you would like to see.",style:  GoogleFonts.itim(color: Colors.black,fontSize: 13),),
              )

              
            ],
          ),
        ),
      );
      }
    );
  }
  
  
  @override
  Widget build(BuildContext context) {
    // ✅ ถ้ากำลังโหลดครั้งแรก → แสดง loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ ถ้า error → แสดง error message
    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 150,
            child: Center(child: Text(_errorMessage!)),
          ),
        ),
      );
    }

    // ✅ ถ้าไม่มีข้อมูล → แสดง no data
    if (!controller.isLoaded || controller.allDots.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 150,
            child: const Center(child: Text('No data available')),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BgColor.Bg1.color_code,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: Colors.blue,
          backgroundColor: Colors.white,
          child:SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                            
                    // day
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${_dateToday?[0]}",
                            style: GoogleFonts.itim(fontSize: 25,color: headColor[0]),
                          ),
                          SizedBox(width: 5,),
                          Text(
                            "${_dateToday?[1]}",
                            style: GoogleFonts.itim(fontSize: 25,color: headColor[1]),
                          ),
                          // SizedBox(width: 5,),
                          IconButton(
                            onPressed: () async{
                              showCalendar();
                              
                            },
                            icon: Icon(Icons.date_range_outlined,color: Colors.black,size: 27.5,)
                          )
                        ],
                      ),
                    ),
                            
                    SizedBox(height: 15,),
                            
                    // line charts
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: buildGraphWidget(
                        context: context,
                        dots: controller.allDots,
                        sessionData: controller.sessionData ?? {},
                        docId:  generalId!
                      ),
                    ),
                    
                   
                            
                    SizedBox(height: 15,),
                            
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                      child: buildGategoryBar(category: _categortList!)
                    ),
                            
                    // bottom part
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Container(
                        height: 235,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                
                              // Time brabrabra
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  buildStartEnd(
                                    startend: _startend ?? {},
                                    icon: Icons.timelapse_rounded
                                  ),
                                  buildSleepTime(
                                    sleeptime: _sleeptime ?? '',
                                    icon: Icons.bed_rounded
                                  ),
                                  buildSoreDetial(
                                    snoredetial: _snoredetial!,
                                    icon: Icons.record_voice_over_sharp
                                  ),
                                  
                                ],
                              ),
                              
                              SizedBox(width: 5,),
                                
                              // pie graph & note
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                
                                  // pie charts
                                  Container(
                                    height: 160,
                                    width: 140,
                                    // padding: ,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[200],
                                      borderRadius: BorderRadius.circular(6),
                                     
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        buildPiechart(category: _categortList!),
                                        SizedBox(height:5,),
                                        Text("Summaarize",style:  GoogleFonts.itim(fontSize: 17.5,color: Colors.white),)
                                      ],
                                    )
                                  ),
                                
                                  // add note
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[200],
                                          foregroundColor: Colors.white,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(13),
                                          iconColor: Colors.black,
                                          iconSize: 32,
                                        ),
                                        
                                        onPressed: (){
                                          notedialog(
                                            context: context,
                                            DatabaseNote: _note ?? "Not can't load",
                                          );
                                        },
                                        child: Icon(Icons.list_alt_rounded)
                                      ),
                                      SizedBox(width: 7.5),
                                      Text("See note",style: GoogleFonts.itim(fontSize: 15,color:  Colors.blue, fontWeight: FontWeight.w500),)
                                
                                    ],
                                  )
                                
                                
                                  
                                ],
                              )
                            ],
                            
                          ),
                        ),
                      ),
                    )
                    
                    
                  ],
                ),
              )
          ),
        ),
    );
  }
}


