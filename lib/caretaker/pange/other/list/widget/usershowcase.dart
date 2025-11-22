

import 'package:flutter/material.dart';
import 'package:nornsabai/model/data_model/searchitemmodel.dart';

class Usershowcase extends StatelessWidget {
  final SearchItem user;
  
  const Usershowcase({super.key,required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(vertical: 125,horizontal: 30),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)
        ),
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${user.username}"),
            Text("${user.email}"),
            SizedBox(height: 10,),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue[900]
              ),
              onPressed: () async{

              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add,color: Colors.white,size: 20,),
                  Text("Add general user to list",style: TextStyle(color: Colors.white),)
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}