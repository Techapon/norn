import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
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
      backgroundColor: BgColor.Bg1.color_code,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 50,right: 50,top: 100),
          child: Column(
            children: [


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
                          Text("Request",style: TextStyle(color: Colors.black,fontSize: 75),textAlign: TextAlign.center,),
                          SizedBox(width: 20,),
                          Icon(Icons.mark_email_unread,color:Colors.black,size: 75,)
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
                                      Text("Awaiting response",style: TextStyle(color: BgColor.Bg2Gradient.color_code,fontSize: 32,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                      Text("$count",style: TextStyle(color: BgColor.Bg2Gradient.color_code,fontSize: 40,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                      Text("requests",style: TextStyle(color: BgColor.Bg2Gradient.color_code.withOpacity(0.7),fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
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
                    borderRadius: BorderRadius.only( topLeft: Radius.circular(26) ,topRight: Radius.circular(26)),
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
                        return const Center(child: Text('No incoming requests',style: TextStyle(fontSize: 17.5),));
                      }
          
                      return ListView.builder(
                        itemCount: requestsWithData .length,
                        itemBuilder: (context, index) {
                          final item = requestsWithData[index];
                          final request = item.request;
                          final caretaker = item.caretaker;
          
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: 1,
                                color: Colors.black
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 25,top: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        caretaker?.username ?? 'Unknown User',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        caretaker?.email ?? 'No email',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey[600],
                                        ),
                                      ),
          
                                      Divider(),

                                      Row(
                                        children: [
                                        Text(
                                          'Requested: ${request.formattedCreate}',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[600],
                                          ),
                                        ),
            
                                        Text(
                                          ' ${request.requesttPass} ago',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
          
                                    // Decline Care
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                        ),
                                        onPressed: () async{
                                          MyDiaologAlertFuture(
                                            context: context,
                                            yesText: "Yes,I do",
                                            cancelText: "Calcel",
                                            mainText: "Decline care",
                                            desscrip: "Are you sure to decile?",
                                            whenSuccess: "Decline care success!!",
                                            whenFail: "Decline care fail,Please try again",
                                            onpressed: () async{
                                              final result = await incarecontroller.declineRequest(
                                                generalUserId: widget.userdocid!,
                                                docId: request.docId,
                                                caretakerId: request.fromCaretakerId ?? '',
                                                requestData: request.toMap(),
                                              );
          
                                              return result["success"];
                                            }
                                          );
                                        },
                                        child: Text("decline",style: TextStyle(color: Colors.red,fontSize: 20),)
                                      ),
                                    ),
          
                                    // Appect Care
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () async{
                                          MyDiaologAlertFuture(
                                            context: context,
                                            yesText: "Yes,I do",
                                            cancelText: "Calcel",
                                            mainText: "Accept care",
                                            desscrip: "Are you sure to accept?",
                                            whenSuccess: "Accept care success!!",
                                            whenFail: "Accept care fail,Please try again",
                                            onpressed: () async{
                                              final result = await incarecontroller.acceptRequest(
                                                generalUserId: widget.userdocid!,
                                                docId: request.docId,
                                                caretakerId: request.fromCaretakerId ?? '',
                                                requestData: request.toMap(),
                                              );
          
                                              return result["success"];
                                            }
                                          );
                                        },
                                        child: Text("Accept",style: TextStyle(color: Colors.blue,fontSize: 20),)
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
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