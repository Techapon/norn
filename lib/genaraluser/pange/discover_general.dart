
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

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
                      Text("Discover",style: TextStyle  (color: BgColor.BottomNav_bg.color_code ,fontSize: 45,fontWeight: FontWeight.bold),),
                      SizedBox(width: 10,),
                      Icon(Icons.search_rounded,color: Colors.black,size: 50,)
                    ],
                  ),
                ),
              ],
            ),
        
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {

                  Color maintextcolor  = BgColor.BottomNav_bg.color_code;

                  return Container(
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
                              color: Color(0xFF002844),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.nightlight_rounded,color: Colors.white,size: 28,),
                          )
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "in science base"
                              ,style: TextStyle(color: Color(0xFF003F6D),fontSize: 25,fontWeight: FontWeight.bold),
                            ),

                            Row(
                              children: [
                                Text("- ",style:  TextStyle(color: Color(0xFF003F6D),fontSize: 40,fontWeight: FontWeight.bold)),
                                Text("What is snore?",style:  TextStyle(color: maintextcolor,fontSize: 40,fontWeight: FontWeight.bold))
                              ],
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
                                "image/discover1.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),

                            // turn to text span
                            Text(
                              "Snoring is the hoarse or harsh sound that occurs when air flows past relaxed tissues in your throat, causing the tissues to vibrate as you breathe. Nearly everyone snores now and then, but for some people it can be a chronic problem. Sometimes it may also indicate a serious health condition. In addition, snoring can be a nuisance to your partner.Lifestyle changes, such as losing weight, avoiding alcohol close to bedtime or sleeping on your side, can help stop snoring.In addition, medical devices and surgery are available that may reduce disruptive snoring. However, these aren't suitable or necessary for everyone who snores.",
                              style: TextStyle(color: Color(0xFF003F6D),fontSize: 30,fontWeight: FontWeight.w100),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),



            

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