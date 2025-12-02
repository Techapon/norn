
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/My_widget/MylistpeopleW.dart';
import 'package:nornsabai/My_widget/MyrequestW.dart';
import 'package:nornsabai/Myfunction/caretakerfunc/mainfunc/takecaresystem/carecontroller.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/addPage.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

class RequestCare extends StatefulWidget {
  final String careDocId;

  RequestCare({required this.careDocId});

  @override
  State<RequestCare> createState() => _RequestCareState();
}

class _RequestCareState extends State<RequestCare> {
  final CaretakerFriendSystem carecontroller = CaretakerFriendSystem(); 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 20,right:20,top: 40),
        child: Column(
          children: [

            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(26)
              ),
              child: Container(
                
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(400),
                    topRight: Radius.circular(26),
                    bottomLeft: Radius.circular(26),
                    bottomRight: Radius.circular(26),
                  ),
                ),
                padding: EdgeInsets.all(15),
                child: Column(
                  
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.account_circle_rounded,color: Colors.grey[500],size: 85,),
                        SizedBox(width: 5,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Request Care",style: TextStyle(color: Colors.black,fontSize: 35,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                            Text("your request will be here",style: TextStyle(height: 0.8,color: Colors.black.withOpacity(.47),fontSize: 13,),textAlign: TextAlign.center,),
                          ],
                        ),
                      ],
                    ),
              
                    Divider(),
              
                    // ใช้ getPendingRequestCount ที่นี้
                    Row(
                      children: [

                        Expanded(
                          child: StreamBuilder<int>(
                            stream: carecontroller.getCaretakerCount(widget.careDocId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              final count = snapshot.data ?? 0;
                                        
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("Receiving care",style: TextStyle(color: BgColor.BottomNav_bg.color_code,fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                          Text("$count",style: TextStyle(color: BgColor.BottomNav_bg.color_code,fontSize: 22,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                          Text("persons",style: TextStyle(color: BgColor.BottomNav_bg.color_code.withOpacity(0.7),fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                          ),
                        ),

                        Expanded(
                          child: StreamBuilder<int>(
                            stream: carecontroller.getPendingRequestCount(widget.careDocId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              final count = snapshot.data ?? 0;
                                            
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("Request pending",style: TextStyle(color:Colors.green[500],fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                          Text("$count",style: TextStyle(color:Colors.green[500],fontSize: 22,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                          Text("request",style: TextStyle(color:const Color.fromARGB(255, 76, 175, 80).withOpacity(0.7),fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                          ),
                        ),

                        
                      ],
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
                padding: EdgeInsets.only(top: 25,left: 20,right: 20),
                child: StreamBuilder<List<FriendRequestWithUserData>>(
                  stream: carecontroller.getRequestsListWithUserData(widget.careDocId),
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
                            Icon(Icons.inbox,color: BgColor.Bg2Gradient.color_code ,size: 80,),
                            Text("You dont't have any request",style: TextStyle(fontSize: 18,color: Colors.black),)
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
                        
                        return MyrequestCa(
                          request: request,
                          generak: item.targetUser,
                          incarecontroller: carecontroller,
                          userdocid: widget.careDocId,
                        );

                      }
                    );
                  }
                ),
              ),
            )
           
            // Expanded(
            //   child: Container(
            //     child: StreamBuilder<List<FriendRequestWithUserData>>(
            //       stream: carecontroller.getRequestsListWithUserData(widget.careDocId),
            //       builder: (context, snapshot) {

            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return const Center(child: CircularProgressIndicator());
            //         }

            //         if (snapshot.hasError) {
            //           return Center(child: Text('Error: ${snapshot.error}'));
            //         }

            //         final requestsWithData = snapshot.data ?? [];

            //         if (requestsWithData.isEmpty) {
            //           return const Center(child: Text('No pending requests'));
            //         }

            //         return ListView.builder(
            //           itemCount: requestsWithData.length,
            //           itemBuilder: (context, index) {
            //             final request = requestsWithData[index];

            //             return Container(
            //               margin: EdgeInsets.symmetric(vertical: 10),
            //               decoration: BoxDecoration(
            //                 color: Colors.white,
            //                 borderRadius: BorderRadius.circular(12),
            //                 border: Border.all(
            //                   width: 1,
            //                   color: Colors.black
            //                 )
            //               ),
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Padding(
            //                     padding: EdgeInsets.only(left: 20,top: 10),
            //                     child: Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Text(
            //                           request.targetUser?.username ?? 'Unknown User',
            //                         ),
            //                         Text(
            //                           request.targetUser?.email ?? 'No email',
            //                         ),

            //                         Divider(),

            //                         Text(
            //                           'Requested: ${request.request.formattedCreate}',
            //                           style: TextStyle(
            //                             fontSize: 12,
            //                             color: Colors.grey[600],
            //                           ),
            //                         ),

            //                         Text(
            //                           'its: ${request.request.requesttPass} ago',
            //                           style: TextStyle(
            //                             fontSize: 12,
            //                             color: Colors.grey[600],
            //                           ),
            //                         ),

            //                       ],
            //                     ),
            //                   ),
            //                   Row(
            //                     children: [

            //                       // Cancel Request
            //                       Expanded(
            //                         child: TextButton(
            //                           onPressed: () async{
            //                             MyDiaologAlertFuture(
            //                               context: context,
            //                               yesText: "Yes,I do",
            //                               cancelText: "Calcel",
            //                               mainText: "Cancel care",
            //                               desscrip: "Are you sure to Cancel?",
            //                               whenSuccess: "Cancel care success!!",
            //                               whenFail: "Cancel care fail,Please try again",
            //                               onpressed: () async{
            //                                 final result = await carecontroller.cancelRequest(
            //                                   caretakerId: widget.careDocId,
            //                                   docId: request.request.docId,
            //                                   targetUserId: request.request.targetUserId ?? ''
            //                                 );

            //                                 return result["success"];
            //                               }
            //                             );
            //                           },
            //                           child: Text("cancel")
            //                         ),
            //                       ),

            //                     ],
            //                   ),
            //                 ],
            //               ),
            //             );
            //           }
            //         );
            //       }
            //     ),
            //   ),
            // )
          ],
        )
      ),
    );
  }
}