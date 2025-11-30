
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/genaraluser/pange/otherpage/discover/page/disfull.dart';
import 'package:nornsabai/model/data_model/discovermodel.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';
import 'package:nornsabai/Myfunction/globalFunc/alarmsystem/function/alarm_func.dart';

class DiscoverGeneral extends StatelessWidget {
  const DiscoverGeneral({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 110),
        child: Column(
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Row(
                    children: [
                      Text("Discover",style: TextStyle(color: BgColor.BottomNav_bg.color_code ,fontSize: 45,fontWeight: FontWeight.bold),),
                      SizedBox(width: 10,),
                      Icon(Icons.search_rounded,color: Colors.black,size: 50,)
                    ],
                  ),
                ),
              ],
            ),
        
            Expanded(
              child: ListView.builder(
                itemCount: discoverList.length,
                itemBuilder: (context, index) {

                  Color maintextcolor  = BgColor.BottomNav_bg.color_code;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(30),

                    child: Stack(
                      
                      children: [

                        // icon
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: discoverList[index].colortheme,
                              shape: BoxShape.circle,
                            ),
                            child: Icon( discoverList[index].icon ,color: Colors.white,size: 28,),
                          )
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${discoverList[index].section}",
                              style: TextStyle(color: discoverList[index].colortheme,fontSize: 25,fontWeight: FontWeight.bold),
                            ),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text("- ",style:  TextStyle(color: discoverList[index].colortheme,fontSize: 35,fontWeight: FontWeight.bold)),
                                  Text("${discoverList[index].title}",style:  TextStyle(color: maintextcolor,fontSize: 35,fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),

                            Container(
                              height: 375,
                              margin: EdgeInsets.symmetric(vertical: 17.5),
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Image.asset(
                                discoverList[index].image,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // turn to text span
                            Text(
                              "${discoverList[index].textcontent}",
                              style: TextStyle(color: Color(0xFF003F6D),fontSize: 27,fontWeight: FontWeight.w100),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),


                            // read more

                            SizedBox(height: 10,),

                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Disfull(discoverModel: discoverList[index],);
                                  }
                                );
                              },
                              child: Text("read more",style: TextStyle(
                                color: Color(0xFF003F6D),
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF003F6D),
                                decorationThickness: 1.5,
                              ),)
                            )

                          ],
                        )
                      ],

                    ),
                  );
                },
              )
            )
          ],
        ),
      ),
    );
  }
}