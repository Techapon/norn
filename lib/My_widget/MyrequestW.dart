
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2,
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
                          generalUserId: userdocid!,
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
                          generalUserId: userdocid!,
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
}