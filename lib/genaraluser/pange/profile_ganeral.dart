import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/My_widget/My_settingElement.dart';
import 'package:nornsabai/login.dart';
import 'package:nornsabai/model/reuse_model/bordertype_model.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';
// import 'package:nornsabai/model/reuse_model/color_model.dart';


class ProfileGeneral extends StatelessWidget {
  const ProfileGeneral({super.key});

  // find user
  Future<Map<String,dynamic>?> getuserprofile() async{
    try {
      
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final String userEmail = user.email!;

      // find in user
      final DocumentSnapshot GeneralUser = await FirebaseFirestore.instance
            .collection("General user")
            .doc(userEmail).get();

      if (GeneralUser.exists) {
        final userDoc = GeneralUser.data() as Map<String, dynamic>;
        return {
          "username": userDoc["username"],
          "email": userDoc["email"],
          "phoneNumber": userDoc["phoneNumber"],
          "whoareu": userDoc["General"],
        };
      }

      // find in user
      final DocumentSnapshot Caretaker = await FirebaseFirestore.instance
            .collection("Caretaker")
            .doc(userEmail).get();

      if (Caretaker.exists) {
        final userDoc = Caretaker.data() as Map<String, dynamic>;
        return {
          "username": userDoc["username"],
          "email": userDoc["email"],
          "phoneNumber": userDoc["phoneNumber"],
          "whoareu": userDoc["Caretaker"],
        };
      }


    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // void LogoutDailog(BuildContext context) {
  //   showDialog(context: context, builder: (context) {
  //     return CupertinoAlertDialog(
  //       title: Text("Log out"),
  //       content: Text("Do you want to log out?"),
  //       actions: [
  //         MaterialButton(
  //           onPressed: (){
  //             Navigator.pop(context);
  //           }, 
  //           child: Text("cancel",style: TextStyle(color: Colors.red),)
  //         ),
  //         MaterialButton(
  //           onPressed: 
  //           child: Text("Yes,I do",style: TextStyle(color: Colors.blue),)
  //         ),
  //       ],
  //     );
  //   });
  // }

  @override
  
  Widget build(BuildContext context) {
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
                      email: ". . . ."
                    );
                  }

                  if (snapshot.hasError) {
                    return buildprofile(
                      name: "Error Loading",
                      email: "Please try again"
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return buildprofile(
                      name: "No Profile Found",
                      email: "User data not available"
                    );
                  }

                  final userData = snapshot.data!;
                  return buildprofile(
                    name: userData["username"],
                    email: userData["email"]
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
                borderType: BorderRauisType.single,
                onclick: (){}
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(top: 3.5,bottom: 3.5,left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("App Setting",style: TextStyle(color: Color(0xFF8C8C8C),fontSize: 13),),
                  ],
                ),
              ),

              // Sound setting
              settingElement(
                icon: Icons.volume_up_outlined,
                iconcolor: Color(0xFF6CC7E0),
                title: "Sound setting",
                bold: false,
                borderType: BorderRauisType.top,
                onclick: (){}
              ),

              // Notifications
              settingElement(
                icon: Icons.notifications_active,
                iconcolor: Color(0xFFFF4C00),
                title: "Notifications",
                bold: false,
                borderType: BorderRauisType.center,
                onclick: (){}
              ),

              // Audio file capacity
              settingElement(
                icon: Icons.folder_copy_outlined,
                iconcolor: Color(0xFFEDDC81),
                title: "Audio file capacity",
                bold: false,
                borderType: BorderRauisType.bottom,
                onclick: (){}
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(top: 3.5,bottom: 3.5,left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Sleep Quality",style: TextStyle(color: Color(0xFF8C8C8C),fontSize: 13),),
                  ],
                ),
              ),

              // Health
              settingElement(
                icon: Icons.health_and_safety_outlined,
                iconcolor: Color(0xFF6CC7E0),
                title: "Health",
                bold: false,
                borderType: BorderRauisType.top,
                onclick: (){}
              ),

              // Sleep apnea risk assessment
              settingElement(
                icon: Icons.assessment,
                iconcolor: Color(0xFF8B56C3),
                title: "Sleep apnea risk assessment",
                bold: false,
                borderType: BorderRauisType.center,
                onclick: (){}
              ),

              // A tailored solution for you
              settingElement(
                icon: Icons.check_box_outlined,
                iconcolor: Color(0xFF5DC764),
                title: "A tailored solution for you",
                bold: false,
                borderType: BorderRauisType.bottom,
                onclick: (){}
              ),


              Padding(
                padding: EdgeInsetsGeometry.only(top: 3.5,bottom: 3.5,left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Help & Recommend",style: TextStyle(color: Color(0xFF8C8C8C),fontSize: 13),),
                  ],
                ),
              ),

              // Frequently asked questions
              settingElement(
                icon: Icons.question_mark_outlined,
                iconcolor: Color(0xFFFF7BA9),
                title: "Frequently asked questions",
                bold: false,
                borderType: BorderRauisType.top,
                onclick: (){}
              ),

              // Send feedback
              settingElement(
                icon: Icons.send,
                iconcolor: Color(0xFF3880EB),
                title: "Send feedback",
                bold: false,
                borderType: BorderRauisType.center,
                onclick: (){}
              ),

              //Export data
              settingElement(
                icon: Icons.file_upload_outlined,
                iconcolor: Color(0xFF818181),
                title: "Export data",
                bold: false,
                borderType: BorderRauisType.bottom,
                onclick: (){}
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
                child: Text("Log out",style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w500),)
                ),

                SizedBox(height: 20,),
            ],
          )
        ),
      ),
    );
  }
}