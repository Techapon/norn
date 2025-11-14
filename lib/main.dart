import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nornsabai/login.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
  // try {
  //   await Firebase.initializeApp();
  //   runApp(const MyApp());
  // } catch (e) {
  //    runApp(MaterialApp(
  //     home: Scaffold(
  //       body: Center(
  //         child: Text(
  //           "error : ❌\n$e",
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //     ),
  //   ));
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
