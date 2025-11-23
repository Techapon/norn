
import 'package:flutter/material.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/lookafter/generaldata_main.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';

void IncareShow({
  required context,
  required FriendRequestWithUserData generaldata
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(vertical: 100,horizontal: 20),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)
          ),
          padding: EdgeInsets.symmetric(vertical: 30,horizontal: 20),
          child: Column(
            children: [
              Text("Name : ${generaldata.targetUser?.username ?? 'Unknow'}"),
              Text("Email : ${generaldata.targetUser?.email ?? 'no email'}"),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Generalprofile(generaldata: generaldata,)));
                },
                child: Text("More")
              )
            ],
          ),
        ),
      );
    }
  );
}