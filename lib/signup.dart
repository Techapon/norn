
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:nornsabai/My_widget/My_textbutton.dart';
import 'package:nornsabai/My_widget/My_textform.dart';
import 'package:nornsabai/My_widget/Mybutton_log_and_sigup.dart';
import 'package:nornsabai/Myfunction/My_findaccount.dart';
import 'package:nornsabai/login.dart';
import 'package:nornsabai/model/data_model/usermodel.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';
import 'package:toastification/toastification.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final formkey = GlobalKey<FormState>();
  Usermodel userModel = Usermodel();

  final List<String> whoareu = ["Caretaker","General user"];

  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  Future signUp(context) async{

    // authenticate user
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userModel.email!.trim(),
        password: userModel.password!.trim()
      ).then((value) async {

        Future<bool> userExits = findNameExits(userModel.username!.trim());
        
        if (await userExits) {
          toastification.show(
            context: context,
            title: Text("Error!",style: TextStyle(fontWeight: FontWeight.bold),),
            description: Text("Your usename already exits!!!,Please try again",style: TextStyle(color: Colors.grey,fontSize: 12),),
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            autoCloseDuration: Duration(seconds: 3),
            animationDuration: Duration(milliseconds: 800)
          );
        }else {
          addUserDetails(
            userModel.username!.trim(),
            userModel.password!.trim(),
            userModel.email!.trim(),
            userModel.phoneNumber,
            userModel.whoareu!.trim()
          );

          formkey.currentState!.reset();
          
          // Toast
          toastification.show(
            context: context,
            title: Text("Sign up is complete!",style: TextStyle(fontWeight: FontWeight.bold),),
            description: Text("Let's Login!!",style: TextStyle(color: Colors.grey,fontSize: 12),),
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            autoCloseDuration: Duration(seconds: 3),
            animationDuration: Duration(milliseconds: 800)
          );

          Navigator.pushReplacement(context,MaterialPageRoute(
            builder: (context) => LoginPage()
          ));
        }

        // add detail
      });
    }on FirebaseAuthException catch(e) {
      String message = "";
      switch (e.code) {
        case 'network-request-failed':
          message = 'There is a problem with the internet connection.';
          break;
        case 'user-not-found':
          message = 'User not found';
          break;
        case 'wrong-password':
          message = 'The password is incorrect.';
          break;
        case 'email-already-in-use':
          message = 'This email address is already in use.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters long.';
          break;
        default:
          message = 'Error : ${e.message}';
      }
      // Toast
      toastification.show(
        context: context,
        title: Text("Error!",style: TextStyle(fontWeight: FontWeight.bold),),
        description: Text(message,style: TextStyle(color: Colors.grey,fontSize: 12),),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 800)
      );
    }
  }

  Future addUserDetails(
    String? username,
    String? password,
    String? email,
    int? phoneNumber,
    String? whoareu
  ) async{
    String typeofuser = "";
    switch (whoareu) {
      case "General user" :
        typeofuser = "General user";
        break; 
      case "Caretaker" :
        typeofuser = "Caretaker";
    }
    await FirebaseFirestore.instance.collection(typeofuser).doc().set({
      "username": username,
      "password": password,
      "email": email,
      "phoneNumber": phoneNumber,
      "whoareu":whoareu,
    });


    
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context,snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                children: [
                  Text("Has Error!!"),
                  Text("${snapshot.error}")
                ],
              )
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(),);
        }
        
        // if success
        return Scaffold(
          backgroundColor: BgColor.Bg1.color_code,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Form(
                key: formkey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  
                      // Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 35),
                            child: Image.asset("image/nornsabai_logo.png",width: 150,),
                          ),
                        ],
                      ),

                      InputTextForm(
                        icon: Icon(Icons.person),
                        hintText: "Username",
                        hideinput: false,
                        inputype: TextInputType.text,
                        validate: RequiredValidator(
                          errorText: "Please enter name"
                        ),
                        onsaved: (username) {
                          userModel.username = username;
                        },
                      ),

                      InputTextForm(
                        icon: Icon(Icons.lock_outline),
                        hintText: "Password",
                        hideinput: true,
                        inputype: TextInputType.text,
                        validate: RequiredValidator(
                          errorText: "Please enter password"
                        ),
                        onsaved: (password) {
                          userModel.password = password;
                        },
                      ),

                      InputTextForm(
                        icon: Icon(Icons.email),
                        hintText: "Email",
                        hideinput: false,
                        inputype: TextInputType.emailAddress,
                        validate: MultiValidator([
                          RequiredValidator(errorText: "Please enter email"),
                          EmailValidator(errorText: "Invalid email format"),
                        ]),
                        onsaved: (email) {
                          userModel.email = email;
                        },
                      ),

                      InputTextForm(
                        icon: Icon(Icons.phone),
                        hintText: "Phone Number",
                        hideinput: false,
                        inputype: TextInputType.number,
                        validate: RequiredValidator(
                          errorText: "Please enter phone number"
                        ),
                        onsaved: (phoneNumber) {
                          userModel.phoneNumber = int.parse(phoneNumber!);
                        },
                      ),

                      Stack(
                        children: [
                          Container(
                            height: 50,
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField(
                                value: whoareu[1],
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF4E87C8), size: 27),
                                
                                
                                dropdownColor: Color.fromARGB(255, 224, 245, 255),
                                decoration: InputDecoration(
                                  
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: Color(0xFFB2D3E4),width: 2.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: Color(0xFFB2D3E4),width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: Color(0xFFB2D3E4),width: 2.0),
                                  ),
                                ),
                                          
                                style: TextStyle(fontSize: 16,color: Color.fromARGB(255, 81, 128, 152),fontWeight: FontWeight.w500),
                                
                                hint: Text("",style:  TextStyle(fontSize: 15,color: Color(0xFF61889C)),),
                                items: whoareu.map((eme){
                                  return DropdownMenuItem(
                                    value: eme,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(eme,style:TextStyle(fontSize: 16,color: Color.fromARGB(255, 81, 128, 152),fontWeight: FontWeight.w500),)
                                  );
                                }).toList(),
                                onChanged: (value) {},
                                onSaved: (value) {
                                  userModel.whoareu = value;
                                  print("koko : ${userModel.whoareu}");
                                },
                               
                              ),
                            ),
                          ),

                          Positioned(
                            left: 20,
                            top: 0,
                            child: Container(
                              alignment: Alignment.center,
                              width: 90,
                              decoration: BoxDecoration(
                                color:  BgColor.Bg1.color_code
                              ),
                              child: Text("who are you",style: TextStyle(color: Color(0xFF4E87C8),fontWeight: FontWeight.bold,backgroundColor: BgColor.Bg1.color_code,height: 0.2,fontSize: 15),)
                            )
                          )
                        ],
                      ),


                      SizedBox(height: 20,),

                      LogAndSignButton(
                        text: "Sig Up",
                        onpressed: () async{
                          if (formkey.currentState!.validate()) {
                            userModel.whoareu ??= whoareu[1];
                            formkey.currentState!.save();
                            signUp(context);
                          }
                          
                        }
                      ),

                      SizedBox(height: 10,),
        
                      // Signup here
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account",style: TextStyle(color: Color(0xFF646D70),fontSize: 15),),
                          SizedBox(width: 7.5,),
                          MyTextbutton(
                            text: "Login here",
                            onpressed: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context) => LoginPage()
                              ));
                            } ,
                          )
                        ],
                      )

                    ],
                  ),
                ),
              ),
            )
          )
        );
      }
    );
  }
}


                      // Row(
                      //   children: [
                      //     Flexible(
                      //       flex: 1,
                      //       child: InputTextForm(
                      //         icon: Icon(Icons.transgender),
                      //         hintText: "Gender",
                      //         hideinput: false,
                      //         inputype: TextInputType.emailAddress,
                      //         validate: RequiredValidator(
                      //           errorText: "Please enter gender"
                      //         ),
                      //         onsaved: (gender) {
                      //           userModel.gender = gender;
                      //         },
                      //       ),
                      //     ),

                      //     SizedBox(width: 10,),

                      //     Flexible(
                      //       flex: 1,
                      //       child: InputTextForm(
                      //         icon: Icon(Icons.height),
                      //         hintText: "Height",
                      //         hideinput: false,
                      //         inputype: TextInputType.emailAddress,
                      //         validate: RequiredValidator(
                      //           errorText: "Please enter height"
                      //         ),
                      //         onsaved: (height) {
                      //           userModel.height = double.parse(height!);
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      
                      // Row(
                      //   children: [
                      //     Flexible(
                      //       flex: 1,
                      //       child: InputTextForm(
                      //         icon: Icon(Icons.monitor_weight_rounded),
                      //         hintText: "Weight",
                      //         hideinput: false,
                      //         inputype: TextInputType.emailAddress,
                      //         validate: RequiredValidator(
                      //           errorText: "Please enter gender"
                      //         ),
                      //         onsaved: (weight) {
                      //           userModel.weight = double.parse(weight!);
                      //         },
                      //       ),
                      //     ),

                      //     SizedBox(width: 10,),

                      //     Flexible(
                      //       flex: 1,
                      //       child: InputTextForm(
                      //         icon: Icon(Icons.child_care),
                      //         hintText: "Height",
                      //         hideinput: false,
                      //         inputype: TextInputType.emailAddress,
                      //         validate: RequiredValidator(
                      //           errorText: "Please enter height"
                      //         ),
                      //         onsaved: (height) {
                      //           userModel.height = double.parse(height!);
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),