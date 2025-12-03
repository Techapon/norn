
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String? _apneaseverity;
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
      _apneaseverity = controller.getApneaSeverity();
      
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
      _apneaseverity = controller.getApneaSeverity();

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

        List<List<Map<String, dynamic>>> twinDataTimeList = [];
        List<DateTime> dataTimeList = [];
        
        Map<String, List<Map<String, dynamic>>> sessionsByDate = {};
        
        for (var session in allsleepsession) {
          DateTime sessionDate = session["startTime"] as DateTime;

         
          String dateKey = "${sessionDate.year}-${sessionDate.month}-${sessionDate.day}";
          
          if (!sessionsByDate.containsKey(dateKey)) {
            sessionsByDate[dateKey] = [];
          }
          sessionsByDate[dateKey]!.add(session);
        }
        
      
        sessionsByDate.forEach((dateKey, sessions) {
          if (sessions.length > 1) {
            
            twinDataTimeList.add(sessions);
            print("📅 Found ${sessions.length} sessions on same date: $dateKey");
          }
          
          dataTimeList.add(sessions.first["startTime"] as DateTime);
        });

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
                                        // Check if this date has multiple sessions
                    String dateKey = "${dateClick.year}-${dateClick.month}-${dateClick.day}";
                    List<Map<String, dynamic>>? sessionsOnThisDate;
                    
                    for (var twinList in twinDataTimeList) {
                      DateTime firstSessionDate = twinList.first["startTime"] as DateTime;
                      String twinDateKey = "${firstSessionDate.year}-${firstSessionDate.month}-${firstSessionDate.day}";
                      if (twinDateKey == dateKey) {
                        sessionsOnThisDate = twinList;
                        break;
                      }
                    }
                    
                    // If multiple sessions, show selection dialog
                    if (sessionsOnThisDate != null && sessionsOnThisDate.length > 1) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Select Session",
                                    style: GoogleFonts.itim(fontSize: 25, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Found ${sessionsOnThisDate!.length} sessions on this date",
                                    style: GoogleFonts.itim(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 25),
                                  ...sessionsOnThisDate.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Map<String, dynamic> session = entry.value;
                                    DateTime startTime = controller.parseDateTime(session["startTime"]) ?? DateTime.now();
                                    DateTime endTime = controller.parseDateTime(session["endTime"]) ?? DateTime.now();
                                    
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        tileColor: Colors.blue[50],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(color: Colors.blue.shade200),
                                        ),
                                        title: Text(
                                          "Session ${index + 1}",
                                          style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          "${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}",
                                          style: GoogleFonts.itim(fontSize: 18),
                                        ),
                                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                                        onTap: () {
                                          Navigator.pop(context); // Close selection dialog
                                          
                                          // Show confirmation dialog
                                          MyDiaologAlertFuture(
                                            context: context,
                                            yesText: "Yes,I do",
                                            cancelText: "cancle",
                                            mainText: "Choose sleep session",
                                            whenSuccess: "Session data loaded!!",
                                            whenFail: "Something went wrong,Please try again",
                                            desscrip: "Load session from ${DateFormat('h:mm a').format(startTime)}?",
                                            onpressed: () async{
                                              await controller.loadLatestSession(sessionId: session["id"]);
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
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // Single session, proceed normally
                      Map<String,dynamic> dataResult = findIdByExactDateTime(allsleepsession,dateClick);
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
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            )
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

                    Padding(
                      padding: EdgeInsets.only(top: 15,bottom: 5),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey[300]!
                          )
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: Icon(Icons.account_circle_sharp,color: Colors.grey[500],size: 30,),
                            ),
                            SizedBox(width: 5,),
                            Text("${widget.generaldata.targetUser?.username ?? 'Unknown'}",style: TextStyle(fontSize: 15),)
                          ],
                        ),
                      ),
                    ),
                            
                    // day
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 0),
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

                    // 30/11/2568
                    // bottom part
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Container(
                        // height: 235,
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
                                  SizedBox(height: 13,),
                                  buildSleepTime(
                                    sleeptime: _sleeptime ?? '',
                                    icon: Icons.bed_rounded
                                  ),
                                  SizedBox(height: 13,),
                                  buildSoreDetial(
                                    snoredetial: _snoredetial!,
                                    icon: Icons.record_voice_over_sharp
                                  ),
                                  SizedBox(height: 13,),
                                  buildApneaSeverity(
                                    apneaseverity: _apneaseverity ?? '',
                                    icon: Icons.graphic_eq_sharp
                                  ),
                                  
                                ],
                              ),
                              
                              SizedBox(width: 5),
                                
                              // pie graph & note
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
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

                                  SizedBox(height: 28,),

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


