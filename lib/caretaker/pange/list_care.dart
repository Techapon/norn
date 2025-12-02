
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/My_widget/MylistpeopleW.dart';
import 'package:nornsabai/Myfunction/caretakerfunc/mainfunc/takecaresystem/carecontroller.dart';
import 'package:nornsabai/Myfunction/globalFunc/alarmsystem/screen/alarm_care.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/addPage.dart';
import 'package:nornsabai/caretaker/pange/other/list/sidepage/lookafter/generaldata_main.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

class ListCare extends StatefulWidget {
  final String careDocId;

  ListCare({required this.careDocId});

  @override
  State<ListCare> createState() => _ListCareState();
}

class _ListCareState extends State<ListCare> {
  final CaretakerFriendSystem carecontroller = CaretakerFriendSystem();
  
  // Track users who have already triggered an alarm to prevent duplicates
  final Set<String> _alarmTriggeredUsers = {};

  bool alarm = false;
  
  // Search functionality
  final searchControll = TextEditingController();
  List<FriendRequestWithUserData> allIncareUsers = [];
  List<FriendRequestWithUserData> filteredIncareUsers = [];

  @override
  void dispose() {
    searchControll.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 50,right: 13,left: 13),
        child: Column(
          children: [
        
            // logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("image/norn_noText.png",width: 110,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("List",style: TextStyle(fontSize: 50,fontWeight: FontWeight.bold,color: BgColor.BottomNav_bg.color_code),),
                    Text("of Care Recipients",style: TextStyle(height: 1.0,fontSize: 20,fontWeight: FontWeight.bold,color: BgColor.BottomNav_bg.color_code),),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10,),
        
                  // search user in list
            Row(
              children: [
                Expanded(
                  child: SearchBar(
                      leading: Icon(Icons.search,color: Color(0xFF78AEBA),size: 35,),
                      hintText: "Search",
                      hintStyle: WidgetStateProperty.all(TextStyle(color: Color(0xFF93CCD8))),
                      backgroundColor: WidgetStateProperty.all(Color(0xFFBEEDF7)),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)
                        )
                      ),
                      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 10)),
                            
                      controller: searchControll,
                            
                      onChanged: searchUser
                    ),
                ),
        
                SizedBox(width: 10),
        
                // add friends button
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Color(0xFFBEEDF7),
                    padding: EdgeInsets.all(15),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    )
                  ),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Addpage(carecontroller: carecontroller,careDocId: widget.careDocId,) ));
                    
                  },
                  icon: Icon(Icons.person_add_alt_1_rounded,color: Color(0xFF78AEBA),size: 30,)
                ),
              ],
            ),
        
            SizedBox(height: 20,),
            
            // user in care list
            Expanded(
              child: Container(
                child: StreamBuilder<List<FriendRequestWithUserData>>(
                  stream: carecontroller.getIncareListWithUserData(widget.careDocId),
                  builder: (context, snapshot) {
        
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
        
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
        
                    final requestsWithData = snapshot.data ?? [];
        
                    // Update lists for search functionality
                    allIncareUsers = requestsWithData;
                    
                    // Apply search filter if search text is not empty
                    if (searchControll.text.isEmpty) {
                      filteredIncareUsers = requestsWithData;
                    } else {
                      // Keep the current filtered list (updated by searchUser method)
                      // This prevents resetting the search when stream updates
                    }
        
                    // Check for users who stopped breathing and trigger alarm
                    for (var request in requestsWithData) {
                      final isBreathing = request.targetUser?.isBreathing;
                      final userId = request.targetUser?.userId ?? '';                      
        
                      if (isBreathing == null) {
                        
                        _alarmTriggeredUsers.remove(userId);
                        print("${request.targetUser?.username} is not in sleep session");
        
                        if (alarm) {
                          // if AlarmInCare pop by itself dont pop again
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        }
        
                        alarm = false;
                      } else if (isBreathing == true) {
                        
                        _alarmTriggeredUsers.remove(userId);
                        print("${request.targetUser?.username} is breathing normally");
        
                       
                        if (alarm) {
                          // if AlarmInCare pop by itself dont pop again
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        }
        
                        alarm = false;
                      } else {
                        
                        if (!_alarmTriggeredUsers.contains(userId)) {
                          
                          _alarmTriggeredUsers.add(userId);
                          print('User stopped breathing: Name: ${request.targetUser?.username}, Email: ${request.targetUser?.email}');
                          
                          // Schedule navigation after build phase completes
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            AlarmInCare(
                              username: request.targetUser?.username ?? "Unknow user",
                              email: request.targetUser?.email ?? "Unknow email"
                            );
                          });
        
        
                          alarm = true;
              
                        }
                      }
                    }
        
                    // Use filtered list for display
                    final displayList = filteredIncareUsers.isEmpty && searchControll.text.isNotEmpty 
                        ? <FriendRequestWithUserData>[]
                        : filteredIncareUsers;
        
                    if (displayList.isEmpty && searchControll.text.isEmpty) {
                      return const Center(child: Text('No users in care list'));
                    }
        
                    if (displayList.isEmpty && searchControll.text.isNotEmpty) {
                      return const Center(child: Text('No users found'));
                    }
        
                    return ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final request = displayList[index];
                        
                        return MylistpeopleCa(
                          request: request.request,
                          general: request.targetUser,
                          carecontroller: carecontroller,
                          userdocid: widget.careDocId,
                          onpressed: () {
                             Navigator.of(context).push(MaterialPageRoute(builder: (context) => Generalprofile(generaldata: request,)));
                          },
                        );
                      }
                    );
                  }
                ),
              ),
            )
          ],
        )
      ),
    );
  }

  // Search functionality methods
  void _performSearch(String query) {
    final finding = allIncareUsers.where((userRequest) {
      final username = userRequest.targetUser?.username?.toLowerCase() ?? '';
      final email = userRequest.targetUser?.email?.toLowerCase() ?? '';
      final input = query.toLowerCase();

      return username.contains(input) || email.contains(input);
    }).toList();

    filteredIncareUsers = finding;
  }

  void searchUser(String query) {
    setState(() {
      _performSearch(query);
    });
  }
}