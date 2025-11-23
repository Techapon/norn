
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

  @override
  void initState() {
    super.initState();
    _listenToUsers();
  }
  
  void _listenToUsers() {
    FirebaseFirestore.instance
        .collection('General user') 
        .snapshots()
        .listen(
      (snapshot) {
        final users = snapshot.docs.map((doc) {
          final data = doc.data();
          return SearchItem(
            docid: doc.id,
            username: data['username'] ?? '', 
            email: data['email'] ?? '', 
          );
        }).toList();

        setState(() {
          allGeneralUser = users;

          if (searchControll.text.isEmpty) {
            geneUserList = users;
          } else {
            searchUser(searchControll.text);
          }
          isLoading = false;
        });
      },
      onError: (error) {
        print('Error listening to users: $error');
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Some things went wrong in loading progressing ')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BgColor.Bg1.color_code,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
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
                            ? "There are no users in the system."
                            : "The user you are searching for was not found."
                        ),
                      )
                      : ListView.builder(
                        itemCount: geneUserList.length,
                        itemBuilder: (context, index) {
                        final geneUser = geneUserList[index];

                        return ListTile(
                          leading: CircleAvatar(
                            child:  Text(geneUser.username.isNotEmpty ? geneUser.username[0].toUpperCase() : "?"),
                          ),
                          title: Text(geneUser.username.isNotEmpty ? geneUser.username : "?"),
                          subtitle: Text(geneUser.email),
                          selectedColor: Colors.white,

                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Usershowcase(
                                  user: geneUser,
                                  carecontroller:widget.carecontroller,
                                  careDocId:  widget.careDocId,
                                );
                              }
                            );
                          },

                          trailing: Icon(Icons.add,color: Colors.black,size: 20,),
                        );
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
  void searchUser(String query) {
    final finding = allGeneralUser.where((geneUserItem) {
      final username = geneUserItem.username.toLowerCase();
      final input = query.toLowerCase();

      return username.contains(input);
    }).toList();

    setState(() {
      geneUserList = finding;
    });
    
  }
}



