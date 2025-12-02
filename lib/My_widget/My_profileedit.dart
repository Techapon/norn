
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:toastification/toastification.dart';

class ProfileEdit extends StatelessWidget {
  const ProfileEdit({super.key, required this.inputcontroller, required this.title, required this.hide, required this.userdocId, required this.type});

  final TextEditingController inputcontroller;
  final String title;
  final bool hide;
  final String userdocId;
  final TextInputType type;

  // if hide = true make text in textfeild hiden
  @override
  Widget build(BuildContext context) {

    String passhiden = "";
    while (passhiden.length < inputcontroller.text.length) {
      passhiden += "*";
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.5),
      child: Row(
        children: [
          
          Text("${title} : ",style: TextStyle(color: Colors.white,fontSize: 27.5),),
          SizedBox(width: 10,),
          
          hide 
          ? Text(
              "${passhiden}",
              style: TextStyle(
                fontSize: 27.5,
                color: Colors.white70,
                
                decoration: TextDecoration.underline, 
                decorationColor: Colors.white70,     
                decorationThickness: 1,  

              ),
            )
          
          :Expanded(
            child: TextField(
              keyboardType: type,
              controller: inputcontroller,
              style: TextStyle(color: Colors.white70,fontSize: 27.5),

              obscureText: hide,

              decoration: InputDecoration(
                hintText: "-",
                hintStyle: TextStyle(color: Colors.white70,fontSize: 27.5),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: IconButton(
              style: IconButton.styleFrom(
                foregroundColor: hide ? Colors.white : Colors.transparent,
              ),
              icon: Icon(Icons.edit,color: Colors.white,size: 32,),
              onPressed: (){
                _changePassword(
                  context: context,
                  userDocId: userdocId,
                );
              },
            ),
          ),

        
        ],
      ),
    );
  }
}


  Future<void> _changePassword({
    required BuildContext context,
    required String userDocId,
  }) async {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(vertical: 50,horizontal: 80),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:  BorderRadius.circular(30)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Padding(
                    padding: EdgeInsets.only(top: 30,right: 40,left: 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text("Change password",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),),
                          SizedBox(height: 20,),
                          
                          TextFormField(
                            style: TextStyle(color: Colors.black,fontSize: 25),
                            controller: oldPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Old Password",
                              labelStyle: TextStyle(color: Colors.black,fontSize: 25),
                              errorStyle: TextStyle(color: Colors.red,fontSize: 25),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your old password';
                              }
                              return null;
                            },
                          ),
                      
                          SizedBox(height: 20,),
                      
                          TextFormField(
                            style: TextStyle(color: Colors.black,fontSize: 25),
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "New Password",
                              labelStyle: TextStyle(color: Colors.black,fontSize: 25),
                              errorStyle: TextStyle(color: Colors.red,fontSize: 25),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a new password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              if (value == oldPasswordController.text) {
                                return 'Please enter a different password';
                              }
                              return null;
                            },
                          ),
                      
                          SizedBox(height: 20,),
                      
                          TextFormField(
                            style: TextStyle(color: Colors.black,fontSize: 25),
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Confirm New Password",
                              labelStyle: TextStyle(color: Colors.black,fontSize: 25),
                              errorStyle: TextStyle(color: Colors.red,fontSize: 25),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                      
                          SizedBox(height: 30,),
                      
                        ],
                      ),
                    ),
                  ),


                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancle",style:  TextStyle(fontSize: 25),)
                        ),
                      ),
      
                      // save
                      
                      Expanded(
                        child: TextButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  AuthCredential credential = EmailAuthProvider.credential(
                                    email: user.email!,
                                    password: oldPasswordController.text,
                                  );

                                  MyDiaologAlertLoad(
                                    context: context,
                                    desscrip: "Progessing ...",
                                    pop: false
                                    
                                  );

                                  // pull old password fomr firebase
                                  String oldPassword = await FirebaseFirestore.instance
                                      .collection("General user")
                                      .doc(userDocId)
                                      .get()
                                      .then((value) => value.data()!['password']);

                                  if (oldPassword != oldPasswordController.text) {
                                    Navigator.pop(context);
                                    MyDiaologAlertFail(
                                      context: context,
                                      whenFail: "Your old password is not correct!"
                                    );
                                    return;
                                  }

                                  await user.reauthenticateWithCredential(credential);
                                  await user.updatePassword(newPasswordController.text);
                                  
            
                                  // Update password in Firestore as well (per existing pattern)
                                  await FirebaseFirestore.instance
                                      .collection("General user")
                                      .doc(userDocId)
                                      .update({'password': newPasswordController.text});
                                  
                                  Navigator.pop(context);
                                  MyDiaologAlertSuccess(
                                    context: context,
                                    whenSuccess: "Password changed successfully! "
                                  );
                                  
                                }
                              } on FirebaseAuthException catch (e) {
                                Navigator.pop(context);
                                MyDiaologAlertFail(
                                  context: context,
                                  whenFail: "Error, Something went wrong!"
                                );
                              }
                            }
                          },
                          child: Text("Change Password",style: TextStyle(fontSize: 25),)
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

        );
      },
    );
  }
