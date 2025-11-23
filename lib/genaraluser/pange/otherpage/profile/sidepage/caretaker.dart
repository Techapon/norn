import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
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
      backgroundColor: BgColor.Bg1.color_code,
      body: SafeArea(
        child: Column(
          children: [
            Text("Caretaker",style: TextStyle(color: Colors.white,fontSize: 30),textAlign: TextAlign.center,),

            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
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
                      return const Center(child: Text('No incoming requests'));
                    }

                    return ListView.builder(
                      itemCount: requestsWithData .length,
                      itemBuilder: (context, index) {
                        final item = requestsWithData[index];
                        final request = item.request;
                        final caretaker = item.caretaker;

                        print("--------- ${request}");

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
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
                                padding: EdgeInsets.only(left: 20,top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      caretaker?.username ?? 'Unknown User',
                                    ),
                                    Text(
                                      caretaker?.email ?? 'No email',
                                    ),

                                    Divider(),

                                    Text(
                                      'Accepted: ${request.formattedAccept}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),

                                    Text(
                                      'Accepted passed: ${request.acceptPass} ago',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              Row(
                                children: [

                                  // Cancel Care
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async{
                                        MyDiaologAlertFuture(
                                          context: context,
                                          yesText: "Yes,I do",
                                          cancelText: "Calcel",
                                          mainText: "Cancel care",
                                          desscrip: "Are you sure to Cancel?",
                                          whenSuccess: "Cancel care success!!",
                                          whenFail: "Cancel care fail,Please try again",
                                          onpressed: () async{
                                            final result = await incarecontroller.removeFriend(
                                              generalUserId: widget.userdocid,
                                              docId: request.docId,
                                              caretakerId: request.fromCaretakerId ?? ''
                                            );

                                            return result["success"];
                                          }
                                        );
                                      },
                                      child: Text("cancel care")
                                    ),
                                  ),

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
    );
  }
}