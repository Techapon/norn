import 'package:flutter/material.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/lookafter/generaldata_other/resultuser.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/lookafter/generaldata_other/trend.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';

class Generalprofile extends StatefulWidget {
  final FriendRequestWithUserData generaldata;
  
  const Generalprofile({super.key, required this.generaldata});

  @override
  State<Generalprofile> createState() => _GeneralprofileState();
}

class _GeneralprofileState extends State<Generalprofile> {
  int pageIndex = 0; // 0 = profile, 1 = daily result, 2 = trend
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    
    pages = [
      _buildProfilePage(),
      Resultuser(generaldata: widget.generaldata,),
      Trenduser(generaldata: widget.generaldata,)
    ];
  }

  // หน้า Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: pageIndex == 0, // ถ้าอยู่หน้า profile ให้ pop ได้
        onPopInvoked: (didPop) {
          
          if (!didPop && pageIndex != 0) {
            setState(() {
              pageIndex = 0;
            });
          }
        },
        child: IndexedStack(
          index: pageIndex,
          children: pages,
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Name : ${widget.generaldata.targetUser?.username ?? "Unknown"}"),
              Text("Email : ${widget.generaldata.targetUser?.email ?? "no email"}"),
              Text("ID : ${widget.generaldata.targetUser?.userId ?? "no id"}"),
              
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: () {
                  // เปลี่ยนไปหน้า daily result โดยไม่ต้อง Navigator.push
                  setState(() {
                    pageIndex = 1;
                    print("After trend---------- index $pageIndex");
                  });
                },
                child: const Text("Daily Result")
              ),
        
              const SizedBox(height: 10),
        
              ElevatedButton(
                onPressed: () {
                  // เปลี่ยนไปหน้า trend
                  setState(() {
                    pageIndex = 2;
                    print("After trend---------- index $pageIndex");
                  });
                },
                child: const Text("Trend")
              ),
            ],
          ),
        ),
      ),
    );
  }
}