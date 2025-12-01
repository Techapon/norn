import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/My_widget/MyrequestW.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/incare/incarecontroller.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart' show FriendRequestWithUserData;
import 'package:nornsabai/model/reuse_model/color_model.dart';

class Request extends StatefulWidget {
  final String userdocid;

  Request({super.key,required this.userdocid});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {

  final GeneralUserFriendSystem incarecontroller = GeneralUserFriendSystem();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BgColor.Bg2.color_code,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 50,right: 50,top: 0),
          child: Column(
            children: [

              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: IconButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back_ios_new),
                        color: Colors.black,
                        iconSize: 30,
                      ),
                    ),
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
                          Text("Request",style: TextStyle(color: Colors.black,fontSize: 75),textAlign: TextAlign.center,),
                          SizedBox(width: 20,),
                          SizedBox(
                            height: 60,
                            child: Icon(Icons.mark_email_unread,color: Colors.grey[500],size: 75,)
                          )
                        ],
                      ),
                
                      Divider(),
                
                      // ใช้ getPendingRequestCount ที่นี้
                      StreamBuilder<int>(
                        stream: incarecontroller.getPendingRequestCount(widget.userdocid),
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
                                      Text("Awaiting response",style: TextStyle(color: BgColor.BottomNav_bg.color_code,fontSize: 32,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                      Text("$count",style: TextStyle(color: BgColor.BottomNav_bg.color_code,fontSize: 40,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                      Text("requests",style: TextStyle(color: BgColor.BottomNav_bg.color_code.withOpacity(0.7),fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
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
                    stream: incarecontroller.getRequestsListWithUserData(widget.userdocid),
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
                              Icon(Icons.inbox_rounded,color: BgColor.Bg2Gradient.color_code ,size: 120,),
                              Text('No incoming requests',style: TextStyle(fontSize: 25,color: Colors.black),)
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
          
                          return MyrequestGe(
                            request: request,
                            caretaker: caretaker,
                            incarecontroller: incarecontroller,
                            userdocid: widget.userdocid,
                          );
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
    );
  }
}