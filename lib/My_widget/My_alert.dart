
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';

void MyDiaologAlertFuture({
  required BuildContext context,
  required String yesText,
  required String cancelText,
  required String mainText,
  required String desscrip,
  required String whenSuccess,
  required String whenFail,
  required Future<bool> Function() onpressed,
}) {
  bool isloading = false;
  bool successed = false;
  bool click = false;

  showDialog(
    context: context,
    barrierDismissible: !isloading,   
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
 
          return WillPopScope(
            onWillPop: () async => !isloading,
            child: Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              // insetPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 50),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: isloading
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 70,
                              width: 70,
                              child: CircularProgressIndicator(
                                  color: Colors.grey[200],
                                  strokeWidth: 5.0,
                                  backgroundColor: Colors.grey[300],
                                ),
                            ),
                            SizedBox(height: 20,),
                            Text("Please Wait...",style: GoogleFonts.itim(fontSize: 17.5,color: Colors.black,fontWeight: FontWeight.w400),)
                          ],
                      ),
                    )
                    : !click
                    ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                              children: [
                                Text("${mainText}",style:  GoogleFonts.itim(fontSize: 22.5,fontWeight: FontWeight.bold),),
                                Text("${desscrip}",style:  GoogleFonts.itim(color: Colors.black87,fontSize: 15),textAlign: TextAlign.center,)
                              ],
                            )
                        ),
            
                        // chioce
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
            
                            // cancel
                            Expanded(
                              child: TextButton(
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                                  // backgroundColor: BgColor.Bg1_dark.color_code,
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                child: Text("${cancelText}",style:  GoogleFonts.itim(fontSize: 17.5),)
                              ),
                            ),
            
                            // save
                            Expanded(
                              child: TextButton(
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                  // backgroundColor: BgColor.Bg1_dark.color_code,
                                  foregroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                onPressed: () async{
                                  setStateDialog(() {
                                    isloading = true;
                                    click = true;
                                  });
            
                                  bool? result = await onpressed();

                                  
                                  if (result) {
                                    setStateDialog(() {
                                      successed = true;
                                      isloading = false;
                                      Future.delayed(Duration(seconds: 2)).then((v) {
                                        Navigator.of(context).pop();
                                      });
                                    });
                                  };
                                },
                                child: Text("${yesText}",style:  GoogleFonts.itim(fontSize: 17.5),)
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : successed
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: const Color.fromARGB(255, 63, 189, 67),
                              child: Icon(Icons.check,color: Colors.white,size:40,),
                            ),
                            SizedBox(height: 20,),
                            Text(whenSuccess,style: GoogleFonts.itim(fontSize: 17.5,color: Colors.black,fontWeight: FontWeight.w400),)
                          ],
                      ),
                    )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: const Color.fromARGB(255, 192, 60, 60),
                                child: Icon(Icons.close,color: Colors.white,size:40,),
                              ),
                              SizedBox(height: 20,),
                              Text(whenFail,style: GoogleFonts.itim(fontSize: 17.5,color: Colors.black,fontWeight: FontWeight.w400),)
                            ],
                        ),
                      )
                ),
              )
            ),
          );
        }
      );
    }
  );
}


// -----------------------
// -- NORMAL
// --------------------------

void MyDiaologAlert({
  required BuildContext context,
  required String yesText,
  required String cancelText,
  required String mainText,
  required String desscrip,
  required Function() onpressed,
}) {
  
  showDialog(
    context: context,
    barrierDismissible: true,   
    builder: (BuildContext context) {
      bool isloading = false;
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        // insetPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 50),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6)
            ),
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                        children: [
                          Text("${mainText}",style:  GoogleFonts.itim(fontSize: 22.5,fontWeight: FontWeight.bold),),
                          Text("${desscrip}",style:  GoogleFonts.itim(color: Colors.black87,fontSize: 15),textAlign: TextAlign.center,)
                        ],
                      )
                  ),
      
                  // chioce
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
      
                      // cancel
                      Expanded(
                        child: TextButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                            // backgroundColor: BgColor.Bg1_dark.color_code,
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text("${cancelText}",style:  GoogleFonts.itim(fontSize: 17.5),)
                        ),
                      ),
      
                      // save
                      Expanded(
                        child: TextButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            // backgroundColor: BgColor.Bg1_dark.color_code,
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: onpressed,
                          child: Text("${yesText}",style:  GoogleFonts.itim(fontSize: 17.5),)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ),
        )
      );
    }
  );
}