
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/incare/incarecontroller.dart';
import 'package:slideable/slideable.dart';

class MylistpeopleGe extends StatelessWidget {
  MylistpeopleGe({super.key,required this.request,required this.caretaker,required this.incarecontroller,required this.userdocid});

  final FriendRequestModel request;
  final UserData? caretaker;
  final GeneralUserFriendSystem incarecontroller;
  final String userdocid;

  @override
  Widget build(BuildContext context) {
    return Slideable(
      items: <ActionItems>[
        ActionItems(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
            size: 50,

          ),
          onPress: () {
            MyDiaologAlertFuture(
              context: context,
              yesText: "Yes,I do",
              cancelText: "Calcel",
              mainText: "Delete care",
              desscrip: "Are you sure to delete?",
              whenSuccess: "Delete care success!!",
              whenFail: "Delete care fail,Please try again",
              onpressed: () async{
                final result = await incarecontroller.removeFriend(
                  generalUserId: userdocid!,
                  docId: request.docId,
                  caretakerId: request.fromCaretakerId ?? '',
                );
                return result["success"];
              }
            );
          },
          backgroudColor: Colors.white,
        ),
      ],

      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          width: 1.5,
          color: Color.fromARGB(255, 190, 190, 190)
        )
      ),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      child: Row(
        children: [
          Container(
            child: Icon(Icons.account_circle_sharp,color: Colors.grey[500],size: 90,),
          ),
          SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caretaker?.username ?? 'Unknown User',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left:10),
                child: Text(
                  caretaker?.email ?? 'Unknown Email',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left:10),
                child: Text(
                  "accepted at : ${request.formattedAccept}",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          )
        ],
        )
      ),
    );
  }
}


// MyDiaologAlertFuture(
//   context: context,
//   yesText: "Yes,I do",
//   cancelText: "Calcel",
//   mainText: "Delete care",
//   desscrip: "Are you sure to delete?",
//   whenSuccess: "Delete care success!!",
//   whenFail: "Delete care fail,Please try again",
//   onpressed: () async{
//     final result = await incarecontroller.removeFriend(
//       generalUserId: userdocid!,
//       docId: request.docId,
//       caretakerId: request.fromCaretakerId ?? '',
//     );
//     return result["success"];
//   }
// );