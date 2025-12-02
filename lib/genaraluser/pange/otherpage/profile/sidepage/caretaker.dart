import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/My_widget/MylistpeopleW.dart';
import 'package:nornsabai/My_widget/MyrequestW.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/incare/incarecontroller.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart' show FriendRequestWithUserData;
import 'package:nornsabai/model/reuse_model/color_model.dart';

class Caretaker extends StatefulWidget {
  final String userdocid;

  Caretaker({super.key,required this.userdocid});

  @override
  State<Caretaker> createState() => _CaretakerState();
}

class _CaretakerState extends State<Caretaker> {

  final GeneralUserFriendSystem incarecontroller = GeneralUserFriendSystem();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:[BgColor.Bg2Gradient.color_code,BgColor.Bg2.color_code],
            stops: [0.0,0.1]
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 50,right: 50,top: 0),
            child: Column(
              children: [
        
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.arrow_back_rounded,color: Colors.white,size: 35,),
                            SizedBox(width: 10,),
                            Text("Caretaker",style: TextStyle(color: Colors.white,fontSize: 32.5),),
                          ],
                        )
                      )
                    ],
                  ),
                ),
        
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(26)
                  ),
                  child: Container(
                    // make it white boderrauis 14 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(400),
                        topRight: Radius.circular(26),
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                    ),
                    padding: EdgeInsets.all(27.5),
                    child: Column(
                      
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.account_circle_rounded,color: Colors.grey[500],size: 120,),
                            SizedBox(width: 10,),
                            Text("Caretaker",style: TextStyle(color: Colors.black,fontSize: 75),textAlign: TextAlign.center,),
                            SizedBox(width: 20,),
                            SizedBox(
                              height: 60,
                              child: Icon(Icons.people_alt_sharp,color: Colors.grey[500],size: 75,)
                            )
                          ],
                        ),
                  
                        Divider(),
                  
                        // ใช้ getPendingRequestCount ที่นี้
                        StreamBuilder<int>(
                          stream: incarecontroller.getCaretakerCount(widget.userdocid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            final count = snapshot.data ?? 0;
                  
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("Cared for by",style: TextStyle(color: BgColor.BottomNav_bg.color_code,fontSize: 32,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                        Text("$count",style: TextStyle(color: BgColor.BottomNav_bg.color_code,fontSize: 40,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                        Text("persons",style: TextStyle(color: BgColor.BottomNav_bg.color_code.withOpacity(0.7),fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
        
                SizedBox(height: 30,),
                      
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only( topLeft: Radius.circular(40) ,topRight: Radius.circular(40)),
                    ),
                    padding: EdgeInsets.only(top: 50,left: 40,right: 40),
                    child: StreamBuilder<List<FriendRequestWithUserData>>(
                      stream: incarecontroller.getCaretakerListWithUserData(widget.userdocid),
                      builder: (context, snapshot) {
            
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
            
                        // เกิด error
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
            
                        // ดึงข้อมูล
                        final requestsWithData  = snapshot.data ?? [];
            
                        // ไม่มีข้อมูล
                        if (requestsWithData .isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_off_rounded,color: BgColor.Bg2Gradient.color_code ,size: 120,),
                                Text('No body here',style: TextStyle(fontSize: 25,color: Colors.black),)
                              ],
                            )
                          );
                        }
            
                        return ListView.builder(
                          itemCount: requestsWithData .length,
                          itemBuilder: (context, index) {
                            final item = requestsWithData[index];
                            final request = item.request;
                            final caretaker = item.caretaker;
                            
                            return MylistpeopleGe(
                              request: request,
                              caretaker: caretaker,
                              incarecontroller: incarecontroller,
                              userdocid: widget.userdocid,
                            );
        
                            // return MyrequestGe(
                            //   request: request,
                            //   caretaker: caretaker,
                            //   incarecontroller: incarecontroller,
                            //   userdocid: widget.userdocid,
                            // );
                          }
                        );
                      }
                    ),
                  ),
                )
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}