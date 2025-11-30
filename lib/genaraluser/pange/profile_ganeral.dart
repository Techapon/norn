import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/My_widget/My_settingElement.dart';
import 'package:nornsabai/Myfunction/globalFunc/alarmsystem/function/alarm_func.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/profile/sidepage/caretaker.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/profile/sidepage/request.dart';
import 'package:nornsabai/login.dart';
import 'package:nornsabai/model/reuse_model/bordertype_model.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';
// import 'package:nornsabai/model/reuse_model/color_model.dart';


class ProfileGeneral extends StatelessWidget {
  final String userDocId;

  ProfileGeneral({required this.userDocId});

  // find user
  Future<Map<String,dynamic>?> getuserprofile() async{
    try {
      
      // find in user
      final DocumentSnapshot GeneralUser = await FirebaseFirestore.instance
            .collection("General user")
            .doc(userDocId).get();

      if (GeneralUser.exists) {
        final userDoc = GeneralUser.data() as Map<String, dynamic>;
        return {
          "username": userDoc["username"],
          "email": userDoc["email"],
          "phoneNumber": userDoc["phoneNumber"],
          "whoareu": userDoc["General"],
        };
      }

    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }


  @override  
  Widget build(BuildContext context) {

    void comming() {
      Fluttertoast.showToast(
        msg: "comming soon",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: BgColor.Bg1.color_code,
        textColor: Colors.black,
        fontSize: 16.0,
        
      );
    }
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:[BgColor.Bg2Gradient.color_code,BgColor.Bg2.color_code],
          stops: [0.0,0.08]
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
        child: SafeArea(
          child: Column(
            children: [
              // profile
              FutureBuilder<Map<String, dynamic>?>(
                future: getuserprofile(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState ==  ConnectionState.waiting) {
                    return buildprofile(
                      name: "Loading...",
                      email: ". . . .",
                      iconSize: 60,
                      titleSize: 23,
                    );
                  }

                  if (snapshot.hasError) {
                    return buildprofile(
                      name: "Error Loading",
                      email: "Please try again",
                      iconSize: 60,
                      titleSize: 23,
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return buildprofile(
                      name: "No Profile Found",
                      email: "User data not available",
                      iconSize: 60,
                      titleSize: 23,
                    );
                  }

                  final userData = snapshot.data!;
                  return buildprofile(
                    name: userData["username"],
                    email: userData["email"],
                    iconSize: 60,
                    titleSize: 23,
                  );
                }
              ),

              SizedBox(height: 20,),

              // account
              settingElement(
                icon: Icons.account_circle,
                iconcolor: Colors.transparent,
                title: "Account",
                bold: true,
                bgnone: true,
                borderType: BorderRauisType.single,
                onclick: (){
                  comming();
                },
                iconSize: 35,
                titleSize: 17,
              ),

              Padding(
                padding: EdgeInsets.only(top: 3.5,bottom: 3.5,left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Caretaker",style: TextStyle(color: Color(0xFF8C8C8C),fontSize: 17),),
                  ],
                ),
              ),

              // Caretaker
              settingElement(
                icon: Icons.people_rounded,
                iconcolor: Color.fromARGB(255, 67, 186, 255),
                title: "Caretaker",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.top,
                onclick: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Caretaker(userdocid: userDocId,)));
                },
                iconSize: 35,
                titleSize: 17,
              ),
              
              // Request
              settingElement(
                icon: Icons.mark_email_unread_outlined,
                iconcolor: Color.fromARGB(255, 255, 139, 67),
                title: "Request",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.bottom,
                onclick: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Request(userdocid: userDocId,)));
                },
                iconSize: 35,
                titleSize: 17,
              ),

              Padding(
                padding: EdgeInsets.only(top: 3.5,bottom: 3.5,left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("App Setting",style: TextStyle(color: Color(0xFF8C8C8C),fontSize: 17),),
                  ],
                ),
              ),

              // Sound setting
              settingElement(
                icon: Icons.volume_up_outlined,
                iconcolor: Color(0xFF6CC7E0),
                title: "Sound setting",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.top,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,
              ),

              // Notifications
              settingElement(
                icon: Icons.notifications_active,
                iconcolor: Color(0xFFFF4C00),
                title: "Notifications",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.center,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,
              ),

              // Audio file capacity
              settingElement(
                icon: Icons.folder_copy_outlined,
                iconcolor: Color(0xFFEDDC81),
                title: "Audio file capacity",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.bottom,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,
              ),

              Padding(
                padding: EdgeInsets.only(top: 3.5,bottom: 3.5,left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Sleep Quality",style: TextStyle(color: Color(0xFF8C8C8C),fontSize: 17),),
                  ],
                ),
              ),

              // Health
              settingElement(
                icon: Icons.health_and_safety_outlined,
                iconcolor: Color(0xFF6CC7E0),
                title: "Health",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.top,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,
              ),

              // Sleep apnea risk assessment
              settingElement(
                icon: Icons.assessment,
                iconcolor: Color(0xFF8B56C3),
                title: "Sleep apnea risk assessment",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.center,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,
              ),

              // A tailored solution for you
              settingElement(
                icon: Icons.check_box_outlined,
                iconcolor: Color(0xFF5DC764),
                title: "A tailored solution for you",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.bottom,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,
              ),


              Padding(
                padding: EdgeInsets.only(top: 3.5,bottom: 3.5,left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Help & Recommend",style: TextStyle(color: Color(0xFF8C8C8C),fontSize: 17),),
                  ],
                ),
              ),

              // Frequently asked questions
              settingElement(
                icon: Icons.question_mark_outlined,
                iconcolor: Color(0xFFFF7BA9),
                title: "Frequently asked questions",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.top,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,
              ),

              // Send feedback
              settingElement(
                icon: Icons.send,
                iconcolor: Color(0xFF3880EB),
                title: "Send feedback",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.center,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,  
              ),

              //Export data
              settingElement(
                icon: Icons.file_upload_outlined,
                iconcolor: Color(0xFF818181),
                title: "Export data",
                bold: false,
                bgnone: false,
                borderType: BorderRauisType.bottom,
                onclick: (){comming();},
                iconSize: 35,
                titleSize: 17,
              ),

              SizedBox(height: 50,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 100,vertical: 15),
                  backgroundColor: Color.fromARGB(255, 19, 42, 49)
                ),
                onPressed: (){
                  // Alert
                  MyDiaologAlert(
                    context: context,
                    yesText: "Yes,I do",
                    cancelText: "cancle",
                    mainText: "Log out",
                    desscrip: "Do you want to log out?",
                    onpressed: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false
                        );
                      });
                    }, 
                  );
                },
                child: Text("Log out",style: GoogleFonts.itim(color: Colors.white,fontSize: 26,fontWeight: FontWeight.w500),)
                ),

                SizedBox(height: 20,),
            ],
          )
        ),
      ),
    );
  }
}