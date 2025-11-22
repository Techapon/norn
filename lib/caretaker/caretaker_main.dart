import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/caretakerfunc/mainfunc/takecaresystem/carecontroller.dart';
import 'package:nornsabai/caretaker/pange/list_care.dart';
import 'package:nornsabai/caretaker/pange/profile_care.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

class CaretakerMainPage extends StatefulWidget {
  const CaretakerMainPage({super.key});

  @override
  State<CaretakerMainPage> createState() => _GeneralMainPageState();
}

class _GeneralMainPageState extends State<CaretakerMainPage> {
  int _currentIndex = 0; 

  Color navbarcolor = BgColor.BottomNav_bg.color_code;



  final List<Widget> _pages = [
    ListCare(),
    Center(child: Text('Request Page')),
    ProfileCare(),  
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: BgColor.Bg1.color_code,
      body: IndexedStack(
        index: _currentIndex,
        children:  _pages,
      ),

      bottomNavigationBar: CircleNavBar(
        activeIndex: _currentIndex,
        color: navbarcolor,
        circleWidth: 60,
        height: 90,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
        },
        
        activeIcons: [
          Icon(Icons.list_alt_rounded, color: Colors.white,size: 37.5,),
          Icon(Icons.email, color: Colors.white,size: 37.5,),
          Icon(Icons.account_circle, color: Colors.white,size: 37.5,),
        ],
        
        inactiveIcons: [
          Icon(Icons.list_alt_rounded, color: Colors.white.withOpacity(0.26),size: 37.5,),
          Icon(Icons.email, color: Colors.white.withOpacity(0.26),size: 37.5,),
          Icon(Icons.account_circle, color: Colors.white.withOpacity(0.26),size: 37.5,),
        ],


        levels: ["List", "Request", "Trend"],
        activeLevelsStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          height: 4.5
        ),

        inactiveLevelsStyle: TextStyle(
          color: Colors.white.withOpacity(0)
        ),
      ),
    );
  }
}



