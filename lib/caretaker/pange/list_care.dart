
import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/caretakerfunc/mainfunc/takecaresystem/carecontroller.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/addPage.dart';

class ListCare extends StatefulWidget {
  const ListCare({super.key,required});

  @override
  State<ListCare> createState() => _ListCareState();
}

class _ListCareState extends State<ListCare> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
        child: Column(
          children: [
            // add friends
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Color(0xFFBEEDF7),
                padding: EdgeInsets.all(15),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(24),
                )
              ),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Addpage() ));
              },
              icon: Icon(Icons.person_add_alt_1_rounded,color: Color(0xFF78AEBA),size: 30,)
            ),

            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text("${index}"));
                  }
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}