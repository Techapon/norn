import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/graph/dailygraph.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

class ResultGaneral extends StatefulWidget {
  // const ResultGaneral({Key? key}) : super(key: key);

  @override
  State<ResultGaneral> createState() => ResultGaneralState();
}

class ResultGaneralState extends State<ResultGaneral> {
  final controller = SleepController();
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

  // loading
  bool addnoteLoading = false;

  @override
  void initState() {
    super.initState();
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
      // print("This is note ${_note}");
      
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
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error refreshing: $e');
    }
  }

  // Show Dialog
  final GlobalKey<FormState> _noteFormKey = GlobalKey<FormState>();
  TextEditingController noteField = TextEditingController();
  void showdiaolog({
    required BuildContext context,
    required String DatabaseNote
  }) {

    noteField.text = DatabaseNote;

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
              child: Form(
                // key
                key: _noteFormKey,
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
                      child: Padding(
                        padding: EdgeInsets.all(17.5),
                        child: Column(
                          children: [
            
                            // Field
                            Expanded(
                              child: Container(
                                // decoration: BoxDecoration(color: Colors.white),
                                child: TextFormField(
                                  
                                  controller: noteField,

                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  textAlignVertical: TextAlignVertical.top,
                                  maxLength: 500,
                                  keyboardType: TextInputType.multiline,
                                  cursorColor: Color(0xFFB2D3E4),
                                  style: GoogleFonts.itim(fontSize: 20,color: Color.fromARGB(255, 81, 128, 152),fontWeight: FontWeight.w500),
                                  
                                  
                                  decoration:  InputDecoration(
                                    hintText: "Description...",
                                    hintStyle: GoogleFonts.itim(fontSize: 20,color: Color.fromARGB(255, 81, 128, 152),fontWeight: FontWeight.w500),
                                    counterStyle: TextStyle(color: Colors.black,fontSize: 14),

                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                    ),

                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black54,width: 1)
                                    )
                                  ),
                                ),
                              ),
                            ),
            
                            SizedBox(height: 10,),
            
                            // on save
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                    backgroundColor: BgColor.Bg1_dark.color_code,
                                    foregroundColor: BgColor.Bg1_dark2.color_code,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: BorderSide(color: Colors.black,width: 1)
                                    ),
                                    
                                  ),
                                  onPressed: () async{
                                    String newNote = noteField.text;
                                    MyDiaologAlertFuture(
                                      context: context,
                                      yesText: "Add note",
                                      cancelText: "cancle",
                                      mainText: "Add note",
                                      desscrip: "Do you want to change your note?",
                                      onpressed: () async{
                                        bool addnoteResult = await controller.updateSessionNote(newNote);
                                        
                                        if (addnoteResult) {
                                          setState(() => _note = controller.getNote());
                                        }

                                        if (addnoteResult) {
                                        
                                          print("add note success");
                                        }else {
                                          print("someting went wrong,please try again");
                                        }
                                        return addnoteResult;
                                      },
                                    );
                                  },
                                  child:  Text("save",style: GoogleFonts.itim(color: Colors.black,fontSize: 18),),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
            
                )
              ),
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

    return SafeArea(
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
                        SizedBox(width: 5,),
                        // IconButton(
                        //   onPressed: () {

                        //   },
                        //   icon: Icon(Icons.date_range_outlined,color: Colors.black54,)
                        // )
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
                    ),
                  ),
                  
                 
                          
                  SizedBox(height: 15,),
                          
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: buildGategoryBar(category: _categortList!)
                  ),
                          
                  // bottom part
                  Padding(
                    padding: const EdgeInsets.only(left: 17.5,right: 17.5,top: 25),
                    child: Container(
                      height: 235,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                          // pie graph & note
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              // pie charts
                              Container(
                                height: 160,
                                width: 150,
                                // padding: ,
                                decoration: BoxDecoration(
                                  color: Colors.blue[200],
                                  borderRadius: BorderRadius.circular(2),
                                 
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
                                      showdiaolog(
                                        context: context,
                                        DatabaseNote: _note ?? "Not can't load",
                                      );
                                    },
                                    child: Icon(Icons.add)
                                  ),
                                  SizedBox(width: 7.5),
                                  Text("Add note",style: GoogleFonts.itim(fontSize: 15,color:  Colors.blue, fontWeight: FontWeight.w500),)

                                ],
                              )


                              
                            ],
                          )
                        ],
                        
                      ),
                    ),
                  )
                  
                  
                ],
              ),
            )
        ),
      );
  }
}


