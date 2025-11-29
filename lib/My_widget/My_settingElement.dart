import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/model/reuse_model/bordertype_model.dart';

class settingElement extends StatelessWidget {
  
  final IconData icon;
  final Color iconcolor;
  final String title;
  final bool bold;
  final bool bgnone;
  final BorderRauisType borderType;
  final VoidCallback? onclick;

  // for responsive
  final double iconSize;
  final double titleSize;

  const settingElement({
    super.key,
    required this.icon,
    required this.iconcolor,
    required this.title,
    required this.bold,
    required this.bgnone,
    required this.borderType,
    required this.onclick,
    required this.iconSize,
    required this.titleSize,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Color(0xFF344754),
        foregroundColor:   Color.fromARGB(255, 27, 37, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: borderType.border,
        ),
        side: BorderSide(
          color: Color(0xFF293A46)
        ),
        padding: EdgeInsets.zero
      ),
      onPressed: onclick,
      child: Padding(
        padding: const EdgeInsets.only(right: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.all(iconSize * 0.35),
                  padding: EdgeInsets.all(bgnone ? 0 :iconSize * 0.28),
                  decoration: BoxDecoration(
                    color: bgnone ? Colors.transparent : iconcolor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(icon,color: bgnone ? Color(0xFF8DA2AA) : Colors.white ,size: bgnone ? iconSize *1.6 : iconSize,),
                ),
                Text(
                  title,
                  style: GoogleFonts.itim(color: Colors.white,fontSize: titleSize,fontWeight: bold ? FontWeight.bold : FontWeight.w400),
                )          
              ],
            ),
        
            Icon(Icons.arrow_forward_ios_rounded,color: Colors.grey[300],size: 18,),
          ],
        ),
      )
    );
  }
}


// profile
Widget buildprofile({
  required String name,
  required String email,
  required double iconSize,
  required double titleSize,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Color(0xFF344754),
      borderRadius: BorderRadius.circular(20)
    ),
    child: Row(
      children: [
        Container(
          margin: EdgeInsets.all(iconSize * 0.25),
          padding: EdgeInsets.all(iconSize * 0.14),
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person,color: Colors.white,size: iconSize,),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,style: GoogleFonts.itim(color: Colors.white,fontSize: titleSize,height: 1,fontWeight: FontWeight.bold),),
            SizedBox(height: 4),
            Text(email,style: GoogleFonts.itim(color: Colors.white,fontSize: titleSize-9,height: 1),)
          ],
        ),
      ],
    ),
  );
}




