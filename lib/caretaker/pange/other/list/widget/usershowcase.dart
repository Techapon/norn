

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/Myfunction/caretakerfunc/mainfunc/takecaresystem/carecontroller.dart';
import 'package:nornsabai/model/data_model/searchitemmodel.dart';

class Usershowcase extends StatelessWidget {
  final SearchItem user;
  final CaretakerFriendSystem carecontroller;
  final String careDocId;
  final void Function() setState;
  
  const Usershowcase({
    super.key,
    required this.user,
    required this.carecontroller,
    required this.careDocId,
    required this.setState
  });

  @override
  Widget build(BuildContext context) {
    
    return Dialog(
      insetPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 25),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)
        ),
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: Stack(
          children: [

            // main content
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    // profile
                    Padding(
                      padding: EdgeInsetsGeometry.only(top: 7.5,bottom: 7.5,left: 0,right: 7.5),
                      child: Container(
                        child: Icon(Icons.account_circle_sharp,color: Colors.grey[500],size: 90,),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //  make first charactor to uppercase
                        Text("${user.username[0].toUpperCase()}${user.username.substring(1)}",style: TextStyle(height: 1.0,fontSize: 30,fontWeight: FontWeight.bold,color: Colors.black),),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.email,color: Colors.grey[500],size: 16.5,),
                                  SizedBox(width: 3,),
                                  Text("${user.email}",style: TextStyle(fontSize: 16.5,color: Colors.grey[500]),)
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone,color: Colors.grey[500],size: 16.5,),
                                  SizedBox(width: 3,),
                                  Text("${user.phone}",style: TextStyle(fontSize: 16.5,color: Colors.grey[500]),)
                                ],
                              ),
                            ],
                          )
                        ),
                      ],
                    )
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      
                          Showcaseitem(
                            icon: Icons.person,
                            size: 55,
                            title: "${user.gender}",
                            subtitle: "Gender",
                            color1 : Color.fromARGB(255, 255, 109, 158),
                            color2 : Color.fromARGB(255, 61, 168, 255),
                          ),

                          SizedBox(width: 25,),
                      
                          Showcaseitem(
                            icon: Icons.face,
                            size: 45,
                            title: "${user.age}",
                            subtitle: "Age",
                            color1 : Color.fromARGB(255, 255, 197, 130),
                            color2 :Color.fromARGB(255, 214, 162, 102),
                          ),
                      
                      
                        ],
                      ),
                      
                      SizedBox(height: 20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      
                          Showcaseitem(
                            icon: Icons.monitor_weight_rounded,
                            size: 55,
                            title: "${user.weight}",
                            subtitle: "Weight",
                            color1 : Color.fromARGB(255, 91, 244, 77),
                            color2 : Color.fromARGB(255, 32, 175, 32),
                          ),

                          SizedBox(width: 22,),
                      
                          Showcaseitem(
                            icon: Icons.man_2_rounded,
                            size: 50,
                            title: "${user.height}",
                            subtitle: "Height",
                            color1 : Color.fromARGB(255, 74, 204, 255),
                            color2 :Color.fromARGB(255, 0, 106, 193),
                          )
                      
                        ],
                      ),

                      SizedBox(height: 20,),

                      Divider(),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Send Request",style: TextStyle(fontSize: 22,color: Colors.black,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(right: 7.5,left: 7.5,top: 15,bottom: 20),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            padding: EdgeInsets.symmetric(vertical: 10),
                            foregroundColor: Colors.black
                          ),
                          
                          onPressed: () async{
                            MyDiaologNoasktFuture(
                              context: context,
                              whenSuccess: "Send request success",
                              whenFail: "Send request fail,Pleas try again",
                              function: () async{
                                final result = await carecontroller.sendFriendRequest(
                                  caretakerId: careDocId,
                                  targetUserId: user.docid.trim()
                                );
                                Navigator.pop(context);
                                Navigator.pop(context);
                                setState();
                                return result["success"];
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Send Request",style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
                              SizedBox(width: 10,),
                              Icon(Icons.send,color: Colors.white,size: 18,),
                            ],
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),


            // close
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                style: IconButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                padding: EdgeInsets.zero,
                onPressed: (){
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close,color: Colors.black.withOpacity(.8),size: 25,)
              )
            )
          ],
        ),
      ),
    );
  }
}


class Showcaseitem extends StatelessWidget {
  const Showcaseitem({super.key,
    required this.icon,
    required this.size,
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
  });

  final IconData icon;
  final double size;
  final String title;
  final String subtitle;

  final Color color1;
  final Color color2;

  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
            return LinearGradient(
              colors: [color1,color2 ], // Define your gradient colors
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.9],
            ).createShader(bounds);
          },
            child: Icon(icon,color: Colors.white,size: size,)
          ),
          SizedBox(width: 3,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 22,),
              Text("${title}",style: TextStyle(fontSize: 28.5,color: Colors.black,fontWeight: FontWeight.bold,height: 0.8),),
              Text("${subtitle}",style: TextStyle(fontSize: 18,color: Colors.grey,height: 0.8),),
            ],
          )
        ],
      )
    );
  }
}