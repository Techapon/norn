import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/caretakerfunc/mainfunc/takecaresystem/carecontroller.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/storevoice.dart';
import 'package:nornsabai/caretaker/pange/other/list/widget/usershowcase.dart';
import 'package:nornsabai/model/data_model/searchitemmodel.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

class Addpage extends StatefulWidget {
  final CaretakerFriendSystem carecontroller;
  final String careDocId;

  const Addpage({super.key,required this.carecontroller,required this.careDocId});

  @override
  State<Addpage> createState() => _AddpageState();
}

class _AddpageState extends State<Addpage> {
  final searchControll = TextEditingController();
  List<SearchItem> allGeneralUser = [];
  List<SearchItem> geneUserList = [];
  bool isLoading = true;
  StreamSubscription<QuerySnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _listenToUsers();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    searchControll.dispose();
    super.dispose();
  }
  
  void _listenToUsers() async {
    _userSubscription = FirebaseFirestore.instance
        .collection('General user') 
        .snapshots()
        .listen(
      (snapshot) async {
        if (!mounted) return;
        
        // Refresh excluded user IDs on each update
        final currentExcludedIds = await _getExcludedUserIds();
        
        final users = snapshot.docs
            .where((doc) => !currentExcludedIds.contains(doc.id)) // Filter out excluded users
            .map((doc) {
              final data = doc.data();
              return SearchItem(
                docid: doc.id,
                username: data['username'] ?? '-', 
                email: data['email'] ?? '-', 
                phone: data['phoneNumber'] ?? '-', 

                gender: data['detail']?['gender'] ?? '-', 
                age: (data['detail']?['age'] ?? 0).toInt(), 
                weight: (data['detail']?['weight'] ?? 0).toDouble(), 
                height: (data['detail']?['height'] ?? 0).toDouble(), 
              );
            }).toList();

        setState(() {
          allGeneralUser = users;

          if (searchControll.text.isEmpty) {
            geneUserList = users;
          } else {
            _performSearch(searchControll.text);
          }
          isLoading = false;
        });
      },
      onError: (error) {
        print('Error listening to users: $error');
        if (!mounted) return;
        
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Some things went wrong in loading progressing ')),
        );
      },
    );
  }

  /// Get list of user IDs that should be excluded from the add friend list
  /// (users who already have pending requests or are already in incarelist)
  Future<Set<String>> _getExcludedUserIds() async {
    final excludedIds = <String>{};
    
    try {
      // Get users who already have pending requests
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('Caretaker')
          .doc(widget.careDocId)
          .collection('requests')
          .get();
      
      for (var doc in requestsSnapshot.docs) {
        final targetUserId = doc.data()['targetUserId'] as String?;
        if (targetUserId != null) {
          excludedIds.add(targetUserId);
        }
      }
      
      // Get users who are already in incarelist
      final incarelistSnapshot = await FirebaseFirestore.instance
          .collection('Caretaker')
          .doc(widget.careDocId)
          .collection('incarelist')
          .get();
      
      for (var doc in incarelistSnapshot.docs) {
        final targetUserId = doc.data()['targetUserId'] as String?;
        if (targetUserId != null) {
          excludedIds.add(targetUserId);
        }
      }
    } catch (e) {
      print('Error getting excluded user IDs: $e');
    }
    
    return excludedIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BgColor.Bg1.color_code,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [

                  // back icon
                  IconButton(
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back_rounded,color: Colors.black,size: 25,)
                  ),

                  
                ],
              ),

              SearchBar(
                leading: Icon(Icons.search,color: Color(0xFF78AEBA),size: 35,),
                hintText: "Search",
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

              SizedBox(height: 15,),
              // General user  for add friend!!
              Expanded(
                child: Container(
                  child: isLoading
                    ? Center(
                      child: CircularProgressIndicator(),
                    )
                    : geneUserList.isEmpty
                      ? Center(
                        child: Text(
                          searchControll.text.isEmpty
                            ? "There are no users"
                            : "The user you are searching for was not found."
                        ),
                      )
                      : ListView.builder(
                        itemCount: geneUserList.length,
                        itemBuilder: (context, index) {
                        final geneUser = geneUserList[index];

                        // return ListTile(
   
                        //   title: Text(geneUser.username.isNotEmpty ? geneUser.username : "?"),
                        //   subtitle: Text(geneUser.email),
                        //   selectedColor: Colors.white,

                        //   onTap: () {
                        //     showDialog(
                        //       context: context,
                        //       builder: (BuildContext context) {
                                // return Usershowcase(
                                //   user: geneUser,
                                //   carecontroller:widget.carecontroller,
                                //   careDocId:  widget.careDocId,
                                // );
                        //       }
                        //     );
                        //   },

                        //   trailing: Icon(Icons.add,color: Colors.black,size: 20,),
                        // );

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            // border: Border.all(
                            //   width: 1.5,
                            //   color: Color.fromARGB(255, 190, 190, 190)
                            // )
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.symmetric(vertical: 7.5,horizontal: 10),
                          child: Row(
                            children: [
                              Container(
                                child: Icon(Icons.account_circle_sharp,color: Colors.grey[500],size: 55,),
                              ),
                              SizedBox(width: 10,),
                              
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    geneUser.username.isNotEmpty ? "${geneUser.username[0].toUpperCase()}${geneUser.username.substring(1)}" : "?",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left:5),
                                    child: Text(
                                      geneUser.email,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                        height: 1.0
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.add,color: Colors.black.withOpacity(0.75),size: 25,),
                                      onPressed: () {
                                        print("SHOW--------");
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Usershowcase(
                                              user: geneUser,
                                              carecontroller:widget.carecontroller,
                                              careDocId:  widget.careDocId,
                                              setState: () {
                                                _listenToUsers();
                                              }
                                            );
                                          }
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              
                            ],
                            )
                          );

                        // 
                      }
                    ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  void _performSearch(String query) {
    final finding = allGeneralUser.where((geneUserItem) {
      final username = geneUserItem.username.toLowerCase();
      final input = query.toLowerCase();

      return username.contains(input);
    }).toList();

    geneUserList = finding;
  }

  void searchUser(String query) {
    setState(() {
      _performSearch(query);
    });
  }
}



