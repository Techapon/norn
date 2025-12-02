import 'package:flutter/material.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/lookafter/generaldata_other/resultuser.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/lookafter/generaldata_other/trend.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';

class Generalprofile extends StatefulWidget {
  final FriendRequestWithUserData generaldata;
  
  const Generalprofile({super.key, required this.generaldata});

  @override
  State<Generalprofile> createState() => _GeneralprofileState();
}

class _GeneralprofileState extends State<Generalprofile> {
  int pageIndex = 0; // 0 = profile, 1 = daily result, 2 = trend
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    
    pages = [
      _buildProfilePage(),
      Resultuser(generaldata: widget.generaldata,),
      Trenduser(generaldata: widget.generaldata,)
    ];
  }

  // หน้า Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: pageIndex == 0, // ถ้าอยู่หน้า profile ให้ pop ได้
        onPopInvoked: (didPop) {
          
          if (!didPop && pageIndex != 0) {
            setState(() {
              pageIndex = 0;
            });
          }
        },
        child: IndexedStack(
          index: pageIndex,
          children: pages,
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0,vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.arrow_back_rounded,color: Colors.black,size: 23,),
                            SizedBox(width: 10,),
                            Text("Caretaker",style: TextStyle(color: Colors.black,fontSize: 23),),
                          ],
                        )
                      )
                    ],
                  ),
                ),

                Container(
                  child: Icon(Icons.account_circle_sharp,color: Colors.grey[500],size: 130,),
                ),

                Text(
                  "${widget.generaldata.targetUser?.username ?? "Unknown"}",
                  style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.black),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email,color: Colors.grey[500],size: 16.5,),
                    SizedBox(width: 3,),
                    Text("${widget.generaldata.targetUser?.email ?? "no email"}",style: TextStyle(fontSize: 16.5,color: Colors.grey[500]),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone,color: Colors.grey[500],size: 16.5,),
                    SizedBox(width: 3,),
                    Text("${widget.generaldata.targetUser?.phone ?? "no phone"}",style: TextStyle(fontSize: 16.5,color: Colors.grey[500]),)
                  ],
                ),

                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 7.5,vertical: 0),
                          foregroundColor: Colors.grey,
                          backgroundColor:  Colors.transparent,
                          // side: BorderSide(
                          //   color: Colors.black38,
                          //   width: 1,
                          // ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            pageIndex = 1;
                            
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 14,horizontal: 15),
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(Icons.play_circle_outline_outlined,color: Colors.black,size: 27.5,),
                                  SizedBox(width: 10,),
                                  Text("Sleep result",style:  TextStyle(color: Colors.black,fontSize: 22.5),)
                                ],
                              ),
                            ),


                            Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.grey[500],size: 22.5,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 7.5,vertical: 0),
                          foregroundColor: Colors.grey,
                          backgroundColor:  Colors.transparent,
                          // side: BorderSide(
                          //   color: Colors.black38,
                          //   width: 1,
                          // ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            pageIndex = 2;
                            
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 14,horizontal: 15),
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(Icons.bar_chart_outlined,color: Colors.black,size: 27.5,),
                                  SizedBox(width: 10,),
                                  Text("Sleep Trend",style:  TextStyle(color: Colors.black,fontSize: 22.5),)
                                ],
                              ),
                            ),


                            Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.grey[500],size: 22.5,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),


                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.white,
                //     foregroundColor: Colors.black,
                //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(0),
                //     ),
                //     side: BorderSide(
                //       width: 1,
                //       color: Colors.black
                //     )
                //   ),
                //   onPressed: () {
                //     // เปลี่ยนไปหน้า daily result โดยไม่ต้อง Navigator.push
                    // setState(() {
                    //   pageIndex = 1;
                    //   print("After trend---------- index $pageIndex");
                    // });
                //   },
                //   child: const Text("Daily Result")
                // ),
                    
                // const SizedBox(height: 10),
                    
                // ElevatedButton(
                //   onPressed: () {
                //     // เปลี่ยนไปหน้า trend
                //     setState(() {
                //       pageIndex = 2;
                //       print("After trend---------- index $pageIndex");
                //     });
                //   },
                //   child: const Text("Trend")
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}