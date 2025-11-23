import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/model/reuse_model/bordertype_model.dart';

class settingElement extends StatelessWidget {
  
  final IconData icon;
  final Color iconcolor;
  final String title;
  final bool bold;
  final bool bg;
  final BorderRauisType borderType;
  final VoidCallback? onclick;

  const settingElement({
    super.key,
    required this.icon,
    required this.iconcolor,
    required this.title,
    required this.bold,
    required this.bg,
    required this.borderType,
    required this.onclick,
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
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(bg ? 0 :7),
                  decoration: BoxDecoration(
                    color: bg ? Colors.transparent : iconcolor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(icon,color: bg ? Color(0xFF8DA2AA) : Colors.white ,size: bg ? 35 :25,),
                ),
                Text(
                  title,
                  style: GoogleFonts.itim(color: Colors.white,fontSize: 15,fontWeight: bold ? FontWeight.bold : FontWeight.w400),
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
}) {
  return Container(
    decoration: BoxDecoration(
      color: Color(0xFF344754),
      borderRadius: BorderRadius.circular(20)
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 25,
        child: Icon(Icons.person,color: Colors.white,size: 42.5,),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name,style: GoogleFonts.itim(color: Colors.white,fontSize: 20,height: 1,fontWeight: FontWeight.bold),),
          SizedBox(height: 4),
          Text(email,style: GoogleFonts.itim(color: Colors.white,fontSize: 11,height: 1),)
        ],
      ),
      tileColor: Color.fromARGB(255, 243, 245, 246),
      contentPadding: EdgeInsets.all(11),
    ),
  );
}




