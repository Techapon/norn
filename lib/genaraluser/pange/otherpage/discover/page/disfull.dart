

import 'package:flutter/material.dart';
import 'package:nornsabai/model/data_model/discovermodel.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

class Disfull extends StatelessWidget {
  const Disfull({super.key, required this.discoverModel});

  final DiscoverModel discoverModel;

  @override
  Widget build(BuildContext context) {

    Color maintextcolor  = BgColor.BottomNav_bg.color_code;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 110,vertical: 130),
      child: Container(
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
                  color: discoverModel.colortheme,
                  shape: BoxShape.circle,
                ),
                child: Icon( discoverModel.icon ,color: Colors.white,size: 28,),
              )
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${discoverModel.section}",
                  style: TextStyle(color: discoverModel.colortheme,fontSize: 25,fontWeight: FontWeight.bold),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text("- ",style:  TextStyle(color: discoverModel.colortheme,fontSize: 35,fontWeight: FontWeight.bold)),
                      Text("${discoverModel.title}",style:  TextStyle(color: maintextcolor,fontSize: 35,fontWeight: FontWeight.bold))
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
                    discoverModel.image,
                    fit: BoxFit.cover,
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      "${discoverModel.textcontent}",
                      style: TextStyle(color: Color(0xFF003F6D),fontSize: 27,fontWeight: FontWeight.w100),
                    ),
                  ),
                ),

              ],
            )
          ],

        ),
      )
    );
  }
}