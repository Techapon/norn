import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class firebasecheckWidgetBuild {
  
  // if error
  static Widget buildErrorWidget(AsyncSnapshot<User?> snapshot, {VoidCallback? onRetry}) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,color: Colors.red,size: 80,),
            SizedBox(height: 8,),

            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 10,horizontal: 25),
              child: Text("Has Error!!",style: TextStyle(color : const Color.fromARGB(255, 195, 42, 31),fontWeight: FontWeight.bold,fontSize: 20)),
            ),

            Text("${snapshot.error}",style: TextStyle(color: Colors.grey),),

            SizedBox(height: 10,),

            if (onRetry != null)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 195, 42, 31),
                  textStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                  foregroundColor: Colors.white
                ),
                onPressed: onRetry,
                child: const Text("Try again"),
              )
          ],
        ),
      ),
    );
  }

  static Widget buildLoadWidget() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.black,
            ),
            SizedBox(height: 15,),
            Text("Loading data ...")
          ],
        ),
      ),
    );
  }



  

}
