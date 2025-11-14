import 'package:flutter/material.dart';
import 'package:nornsabai/model/reuse_model/bordertype_model.dart';

class settingElement extends StatelessWidget {
  
  final IconData icon;
  final Color iconcolor;
  final String title;
  final bool bold;
  final BorderRauisType borderType;
  final VoidCallback? onclick;

  const settingElement({
    super.key,
    required this.icon,
    required this.iconcolor,
    required this.title,
    required this.bold,
    required this.borderType,
    required this.onclick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF344754),
        borderRadius: borderType.border,
        border: Border.all(
          color: Color(0xFF293A46)
        )
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconcolor,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(icon,color:Colors.white,size: 25,),
        ),                  

        title: Text(title),
        titleTextStyle: TextStyle(color: Colors.white,fontSize: 15,fontWeight: bold ? FontWeight.bold : FontWeight.w400),
        tileColor: Color.fromARGB(255, 243, 245, 246),
        contentPadding: EdgeInsets.only(top: 3,bottom: 3,left: 10,right: 18.5),
        trailing: Icon(Icons.arrow_forward_ios_sharp,color: Colors.white,size: 18,),
        onTap: onclick,
      ),
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
        backgroundColor: Colors.white,
        radius: 25,
        backgroundImage: AssetImage("image/account_profiles.png"), 
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name,style: TextStyle(color: Colors.white,fontSize: 20,height: 1,fontWeight: FontWeight.bold),),
          SizedBox(height: 4),
          Text(email,style: TextStyle(color: Colors.white,fontSize: 11,height: 1),)
        ],
      ),
      tileColor: Color.fromARGB(255, 243, 245, 246),
      contentPadding: EdgeInsets.all(11),
    ),
  );
}




