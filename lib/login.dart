import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:nornsabai/My_widget/My_textbutton.dart';
import 'package:nornsabai/My_widget/My_textform.dart';
import 'package:nornsabai/My_widget/Mybutton_log_and_sigup.dart';
import 'package:nornsabai/Myfunction/My_findaccount.dart';
import 'package:nornsabai/caretaker/caretaker_main.dart';
import 'package:nornsabai/genaraluser/general_main.dart';
import 'package:nornsabai/model/data_model/usermodel.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';
import 'package:nornsabai/signup.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final formkey = GlobalKey<FormState>();
  Usermodel userModel = Usermodel();

  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  // Login function
  Future login(context) async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userModel.email!.trim(),
        password: userModel.password!.trim()
      ).then((v) async{
        formkey.currentState!.reset();

        // Toast
        toastification.show(
          context: context,
          title: Text("Login success",style: TextStyle(fontWeight: FontWeight.bold),),
          description: Text("We hope you enjoy!!",style: TextStyle(color: Colors.grey,fontSize: 12),),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 800)
        );

        final account = await findAccountByEmail(userModel.email!.trim());
        print("------${account}");
        if (account != null) {
          switch (account["type"]) {
            case "General" :
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => GeneralMainPage() 
              ));
              break;
            case "Caretaker" :
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => CaretakerMainPage() 
              ));
              break;
            default :
              print("No one");
              return;
          }
        }
      });

    }on FirebaseAuthException catch (e) {
      // Toast
      toastification.show(
        context: context,
        title: Text("Error!",style: TextStyle(fontWeight: FontWeight.bold),),
        description: Text(e.code,style: TextStyle(color: Colors.grey,fontSize: 12),),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 800)
      );
      
    }
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
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

        // If success
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
                            child: Image.asset("image/nornsabai_logo.png",width: 170,),
                          ),
                        ],
                      ),
                  
                      // username
                      InputTextForm(
                        icon: Icon(Icons.email_outlined),
                        hintText: "Email",
                        hideinput: false,
                        inputype: TextInputType.emailAddress,
                        validate: RequiredValidator(
                          errorText: "Please enter email"
                        ),
                        onsaved: (email) {
                          userModel.email = email;
                        },
                      ),
                   
                      // password
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
                       
                      // forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [MyTextbutton(
                          text: "Forgot password?",
                          onpressed: (){},
                        )]
                      ),
        
                      SizedBox(height: 12.5,),
                  
                      // Login
                      LogAndSignButton(
                        text: "Login",
                        onpressed: () async{
                          if (formkey.currentState!.validate()) {
                            formkey.currentState!.save();
                            login(context);
                          }
                        },
                      ),
        
                      SizedBox(height: 10,),
        
                      // Signup here
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account",style: TextStyle(color: Color(0xFF646D70),fontSize: 18),),
                          SizedBox(width: 7.5,),
                          MyTextbutton(
                            text: "Signup here",
                            onpressed: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context) => Signup()
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

