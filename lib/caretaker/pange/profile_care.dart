import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/My_widget/My_settingElement.dart';
import 'package:nornsabai/caretaker/pange/other/profile/accountCa.dart';
import 'package:nornsabai/login.dart';
import 'package:nornsabai/model/reuse_model/bordertype_model.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';
// import 'package:nornsabai/model/reuse_model/color_model.dart';


class ProfileCare extends StatelessWidget {
  final String careDocId;

  ProfileCare({required this.careDocId});

  // find user
  Future<Map<String,dynamic>?> getuserprofile() async{
    try {
      // find in caretaker
      final DocumentSnapshot Caretaker = await FirebaseFirestore.instance
            .collection("Caretaker")
            .doc(careDocId).get();

      if (Caretaker.exists) {
        final userDoc = Caretaker.data() as Map<String, dynamic>;
        return {
          "username": userDoc["username"],
          "password": userDoc["password"],
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
          child: FutureBuilder(
            future: getuserprofile(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (asyncSnapshot.hasError) {
                return Center(child: Text('Error Loading Profile"'));
              }

              if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                return Center(child: Text("No Profile Found"));
              }

              final userData = asyncSnapshot.data!;

              return Column(
                children: [
                  // profile
                  buildprofile(
                    name: userData["username"],
                    email: userData["email"],
                    iconSize: 47.5,
                    titleSize: 20,
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccountCa(userDocId: careDocId, userdata: userData,)));
                    },
                    iconSize: 25,
                    titleSize: 15,
                  ),
              
                  Padding(
                    padding: EdgeInsets.only(top: 3.5,bottom: 3.5,left: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("App Setting",style: TextStyle(color: Color(0xFF8C8C8C),fontSize: 13),),
                      ],
                    ),
                  ),
              
                  // Notifications
                  settingElement(
                    icon: Icons.notifications_active,
                    iconcolor: Color(0xFFFF4C00),
                    title: "Notifications",
                    bold: false,
                    bgnone: false,
                    borderType: BorderRauisType.single,
                    onclick: (){},
                    iconSize: 25,
                    titleSize: 15,  
                  ),
              
                 
                  Padding(
                    padding: EdgeInsets.only(top: 3.5,bottom: 3.5,left: 15),
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
                    bgnone: false,
                    borderType: BorderRauisType.top,
                    onclick: (){},
                    iconSize: 25,
                    titleSize: 15, 
                  ),
              
                  // Send feedback
                  settingElement(
                    icon: Icons.send,
                    iconcolor: Color(0xFF3880EB),
                    title: "Send feedback",
                    bold: false,
                    bgnone: false,
                    borderType: BorderRauisType.center,
                    onclick: (){},
                    iconSize: 25,
                    titleSize: 15, 
                  ),
              
                  //Export data
                  settingElement(
                    icon: Icons.file_upload_outlined,
                    iconcolor: Color(0xFF818181),
                    title: "Export data",
                    bold: false,
                    bgnone: false,
                    borderType: BorderRauisType.bottom,
                    onclick: (){},
                    iconSize: 25,
                    titleSize: 15, 
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
                    child: Text("Log out",style: GoogleFonts.itim(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w500),)
                  ),
              
                  SizedBox(height: 20,),
                ],
              );
            }
          )
        ),
      ),
    );
  }
}