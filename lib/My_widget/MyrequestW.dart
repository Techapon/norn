
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/Myfunction/caretakerfunc/mainfunc/takecaresystem/carecontroller.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/incare/incarecontroller.dart';

class MyrequestGe extends StatelessWidget {
  MyrequestGe({super.key,required this.request,required this.caretaker,required this.incarecontroller,required this.userdocid});

  final FriendRequestModel request;
  final UserData? caretaker;
  final GeneralUserFriendSystem incarecontroller;
  final String userdocid;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          width: 1.5,
          color: Color.fromARGB(255, 190, 190, 190)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 190, 190, 190),
                  width:1.5,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10,top: 13,bottom: 13),
              child: Stack(
                children: [
            
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // main datail
                      Container(
                        child: Row(
                          children: [
                  
                            Container(
                              child: Icon(Icons.account_circle_sharp,color: Colors.grey[500],size: 90,),
                            ),
                            SizedBox(width: 10,),
                  
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "request from : ",
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      caretaker?.username ?? 'Unknown User',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                  
                                Padding(
                                  padding: EdgeInsetsGeometry.only(left: 5),
                                  child: Text(
                                    "Sent ${request.requesttPass} ago at ${request.formattedCreateTime}",
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
            
                  // request at
                  Positioned(
                    top: 13,
                    right: 17.5,
                    child: Text(
                      '${request.formattedCreate}',
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.grey[800],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          Row(
            children: [

              // Decline Care
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Color.fromARGB(255, 190, 190, 190),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      backgroundColor: Colors.black.withOpacity(0.03),
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
                            generalUserId: userdocid!,
                            docId: request.docId,
                            caretakerId: request.fromCaretakerId ?? '',
                            requestData: request.toMap(),
                          );
                  
                          return result["success"];
                        }
                      );
                    },
                    child: Text("decline",style: TextStyle(color: Colors.red,fontSize: 26),)
                  ),
                ),
              ),

              // Appect Care
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    backgroundColor: Colors.black.withOpacity(0.03),
                  ),
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
                          generalUserId: userdocid!,
                          docId: request.docId,
                          caretakerId: request.fromCaretakerId ?? '',
                          requestData: request.toMap(),
                        );

                        return result["success"];
                      }
                    );
                  },
                  child: Text("Accept",style: TextStyle(color: Colors.blue,fontSize: 26),)
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}


class MyrequestCa extends StatelessWidget {
  MyrequestCa({super.key,required this.request,required this.generak,required this.incarecontroller,required this.userdocid});

  final FriendRequestModel request;
  final UserData? generak;
  final CaretakerFriendSystem incarecontroller;
  final String userdocid;

  @override
  Widget build(BuildContext context) {

    String generalname = "";
    if ( generak?.username != null) {
      generalname = generak!.username![0].toUpperCase() + generak!.username!.substring(1);
    }else {
      generalname = "Unknown User";
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 3,horizontal: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          width: 1,
          color: Color.fromARGB(255, 190, 190, 190)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
                      
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // main datail
                  Container(
                    child: Row(
                      children: [
              
                        Container(
                          child: Icon(Icons.account_circle_sharp,color: Colors.grey[500],size: 55,),
                        ),
                        SizedBox(width: 3,),
              
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "request to : ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  //  if not null then uppercase
                                  generalname,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
              
                            Padding(
                              padding: EdgeInsetsGeometry.only(left: 2),
                              child: Text(
                                "Request sent ${request.requesttPass} ago at ${request.formattedCreateTime}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
          
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          MyDiaologAlertFuture(
                            context: context,
                            yesText: "Yes,I do",
                            cancelText: "Cancel",
                            mainText: "Cancel request",
                            desscrip: "Are you sure to cancel?",
                            whenSuccess: "Cancel request success!!",
                            whenFail: "Cancel request fail",
                            onpressed: () async{
                              final result = await incarecontroller.cancelRequest(
                                caretakerId: userdocid,
                                docId: request.docId,
                                targetUserId: request.targetUserId ?? '',                            
                              );
          
                              return result["success"];
                            }
                          );
                        },
          
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                          child: Text(
                            "calcel",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.red, 
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
          
                ],
              ),
                      
              // request at
              Positioned(
                top: 8.5,
                right: 17.5,
                child: Text(
                  '${request.formattedCreate}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

