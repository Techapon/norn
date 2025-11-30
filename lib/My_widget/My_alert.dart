
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
  print("Head loading $isloading");
  bool successed = false;
  bool click = false;

  showDialog(
    context: context,
    barrierDismissible: true,   
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {

          final mediascreen = MediaQuery.of(context).size.width;
          
          double maintextscale = mediascreen / 18;
          double desscripscale = maintextscale * 0.8;

          double insetpadding = maintextscale  * 3.0;
          double alrtpadding = maintextscale  * 0.9;
          double btnpadding = maintextscale  * 0.4;

          double loadingsize = maintextscale  * 2.8;
          double iconraduis = maintextscale  * 1.4;
          double iconsize = maintextscale  * 1.6;

          double borderraduis = maintextscale  * 0.24;

 
          return WillPopScope(
            onWillPop: () async => !isloading,
            child: Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              insetPadding: EdgeInsets.symmetric(vertical: 0,horizontal: insetpadding),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderraduis)
                  ),
                  child: isloading
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: alrtpadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: loadingsize,
                              width: loadingsize,
                              child: CircularProgressIndicator(
                                  color: Colors.grey[200],
                                  strokeWidth: 5.0,
                                  backgroundColor: Colors.grey[300],
                                ),
                            ),
                            SizedBox(height: 20,),
                            Text("Please Wait...",style: GoogleFonts.itim(fontSize: desscripscale ,color: Colors.black,fontWeight: FontWeight.w400),)
                          ],
                      ),
                    )
                    : !click
                    ? Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: alrtpadding),
                          child: Column(
                              children: [
                                Text("${mainText}",style:  GoogleFonts.itim(fontSize: maintextscale,fontWeight: FontWeight.bold),),
                                Text("${desscrip}",style:  GoogleFonts.itim(color: Colors.black87,fontSize:  desscripscale),textAlign: TextAlign.center,)
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
                                  padding: EdgeInsets.symmetric(horizontal: 0,vertical: btnpadding),
                                  // backgroundColor: BgColor.Bg1_dark.color_code,
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                child: Text("${cancelText}",style:  GoogleFonts.itim(fontSize: desscripscale),textAlign: TextAlign.center,)
                              ),
                            ),
            
                            // save
                            Expanded(
                              child: TextButton(
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 0,vertical: btnpadding),
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

                                  setStateDialog(() {
                                    successed = result;
                                    isloading = false;
                                    print("isloading is $isloading");
                                  });

                                  if (result) {
                                    Future.delayed(Duration(seconds: 2)).then((_) {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                                child: Text("${yesText}",style:  GoogleFonts.itim(fontSize: desscripscale),)
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : successed
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: alrtpadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: iconraduis,
                              backgroundColor: const Color.fromARGB(255, 63, 189, 67),
                              child: Icon(Icons.check,color: Colors.white,size: iconsize,),
                            ),
                            SizedBox(height: 20,),
                            Text(whenSuccess,style: GoogleFonts.itim(fontSize: desscripscale,color: Colors.black,fontWeight: FontWeight.w400),textAlign: TextAlign.center,)
                          ],
                      ),
                    )
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: alrtpadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: iconraduis,
                                backgroundColor: const Color.fromARGB(255, 192, 60, 60),
                                child: Icon(Icons.close,color: Colors.white,size: iconsize,),
                              ),
                              SizedBox(height: 20,),
                              Text(whenFail,style: GoogleFonts.itim(fontSize: desscripscale,color: Colors.black,fontWeight: FontWeight.w400),)
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

      final mediascreen = MediaQuery.of(context).size.width;
      
      double maintextscale = mediascreen / 20;
      double desscripscale = maintextscale * 0.7;

      double insetpadding = maintextscale  * 4.0;
      double alrtpadding = maintextscale  * 0.8;
      double btnpadding = maintextscale  * 0.4;

      // double loadingsize = maintextscale  * 2.8;
      // double iconraduis = maintextscale  * 1.4;
      // double iconsize = maintextscale  * 1.6;

      double borderraduis = maintextscale  * 0.24;

      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        insetPadding: EdgeInsets.symmetric(vertical: 0,horizontal: insetpadding),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderraduis)
            ),
            child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: alrtpadding),
                    child: Column(
                        children: [
                          Text("${mainText}",style:  GoogleFonts.itim(fontSize: maintextscale,fontWeight: FontWeight.bold),),
                          Text("${desscrip}",style:  GoogleFonts.itim(color: Colors.black87,fontSize: desscripscale),textAlign: TextAlign.center,)
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
                            padding: EdgeInsets.symmetric(horizontal: 0,vertical: btnpadding),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text("${cancelText}",style:  GoogleFonts.itim(fontSize: desscripscale),)
                        ),
                      ),
      
                      // save
                      Expanded(
                        child: TextButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: btnpadding),
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: onpressed,
                          child: Text("${yesText}",style:  GoogleFonts.itim(fontSize: desscripscale),)
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







void MyDiaologNoasktFuture({
  required BuildContext context,
  required final String whenSuccess,
  required final String whenFail,
  required Future<bool> Function() function
}) {
  bool isloading = true;
  bool successed = false;

  showDialog(
    context: context,
    barrierDismissible: true,   
    builder: (BuildContext context) {
    
    final mediascreen = MediaQuery.of(context).size.width;

    double maintextscale = mediascreen / 20;
    double desscripscale = maintextscale * 0.7;

    double insetpadding = maintextscale  * 4.0;
    double alrtpadding = maintextscale  * 0.8;
    // double btnpadding = maintextscale  * 0.4;

    double loadingsize = maintextscale  * 2.8;
    double iconraduis = maintextscale  * 1.4;
    double iconsize = maintextscale  * 1.6;

    double borderraduis = maintextscale  * 0.24;


      return StatefulBuilder(
        builder: (context, setStateDialog) {
                    // เรียก future หลังจาก dialog ถูกสร้าง
          Future.microtask(() async {
            if (isloading) {

              bool result = await function();

              setStateDialog(() {
                successed = result;
                isloading = false;
                print("isloading is $isloading");
              });

              // ปิดหลัง 2 วิถ้าสำเร็จ
              if (result) {
                Future.delayed(Duration(seconds: 4)).then((_) {
                  Navigator.of(context).pop();
                });
              }
            }
          });

          return WillPopScope(
            onWillPop: () async => !isloading,
            child: Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              insetPadding: EdgeInsets.symmetric(vertical: 0,horizontal: insetpadding),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderraduis)
                  ),
                  child: isloading
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: alrtpadding,horizontal: alrtpadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: loadingsize,
                              width: loadingsize,
                              child: CircularProgressIndicator(
                                  color: Colors.grey[200],
                                  strokeWidth: 5.0,
                                  backgroundColor: Colors.grey[300],
                                ),
                            ),
                            SizedBox(height: 20,),
                            Text("Please Wait...",style: GoogleFonts.itim(fontSize: desscripscale,color: Colors.black,fontWeight: FontWeight.w400),)
                          ],
                      ),
                    )
                    : successed
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: alrtpadding,horizontal: alrtpadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: iconraduis,
                              backgroundColor: const Color.fromARGB(255, 63, 189, 67),
                              child: Icon(Icons.check,color: Colors.white,size: iconsize,),
                            ),
                            SizedBox(height: 20,),
                            Text(whenSuccess,style: GoogleFonts.itim(fontSize: desscripscale,color: Colors.black,fontWeight: FontWeight.w400),)
                          ],
                      ),
                    )
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: alrtpadding,horizontal: alrtpadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: iconraduis,
                                backgroundColor: const Color.fromARGB(255, 192, 60, 60),
                                child: Icon(Icons.close,color: Colors.white,size: iconsize,),
                              ),
                              SizedBox(height: 20,),
                              Text(whenFail,style: GoogleFonts.itim(fontSize: desscripscale,color: Colors.black,fontWeight: FontWeight.w400),)
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



// --------------------------
//   SIGLE 
// --------------------------


void MyDiaologAlertLoad({
  required BuildContext context,
  required String desscrip,
  required bool pop
}) {
  
  showDialog(
    context: context,
    barrierDismissible: pop,   
    builder: (BuildContext context) {

    final mediascreen = MediaQuery.of(context).size.width;

    double maintextscale = mediascreen / 20;
    // double desscripscale = maintextscale * 0.7;

    double insetpadding = maintextscale  * 4.0;
    double alrtpadding = maintextscale  * 0.8;
    // double btnpadding = maintextscale  * 0.4;

    double loadingsize = maintextscale  * 2.8;
    // double iconraduis = maintextscale  * 1.4;
    // double iconsize = maintextscale  * 1.6;

    double borderraduis = maintextscale  * 0.24;

      return WillPopScope(
        onWillPop: () async => pop,
        child: Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          insetPadding: EdgeInsets.symmetric(vertical: alrtpadding,horizontal: alrtpadding),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderraduis)
              ),
              child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: alrtpadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: loadingsize,
                              width: loadingsize,
                              child: CircularProgressIndicator(
                                  color: Colors.grey[200],
                                  strokeWidth: 5.0,
                                  backgroundColor: Colors.grey[300],
                                ),
                            ),
                            SizedBox(height: 20,),
                            Text(desscrip,style: GoogleFonts.itim(fontSize: 17.5,color: Colors.black,fontWeight: FontWeight.w400),)
                          ],
                      ),
                    ),
                  ],
                ),
            ),
          )
        ),
      );
    }
  );
}


void MyDiaologAlertSuccess({
  required BuildContext context,
  required String whenSuccess,
}) {
  
  showDialog(
    context: context,
    barrierDismissible: true,   
    builder: (BuildContext context) {

      final mediascreen = MediaQuery.of(context).size.width;

      double maintextscale = mediascreen / 20;
      double desscripscale = maintextscale * 0.7;

      double insetpadding = maintextscale  * 4.0;
      double alrtpadding = maintextscale  * 0.8;
      // double btnpadding = maintextscale  * 0.4;

      // double loadingsize = maintextscale  * 2.8;
      double iconraduis = maintextscale  * 1.4;
      double iconsize = maintextscale  * 1.6;

      double borderraduis = maintextscale  * 0.24;
    
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderraduis),
        ),
        insetPadding: EdgeInsets.symmetric(vertical: 0,horizontal: insetpadding),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6)
            ),
            child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: alrtpadding,horizontal: alrtpadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: iconraduis,
                              backgroundColor: const Color.fromARGB(255, 63, 189, 67),
                              child: Icon(Icons.check,color: Colors.white,size:iconsize,),
                            ),
                            SizedBox(height: 20,),
                            Text(whenSuccess,style: GoogleFonts.itim(fontSize: desscripscale,color: Colors.black,fontWeight: FontWeight.w400),)
                          ],
                      ),
                    )
                ],
              ),
          ),
        )
      );
    }
  );
}


//   FAIL

void MyDiaologAlertFail({
  required BuildContext context,
  required String whenFail,
}) {
  
  showDialog(
    context: context,
    barrierDismissible: true,   
    builder: (BuildContext context) {

      final mediascreen = MediaQuery.of(context).size.width;

      double maintextscale = mediascreen / 20;
      double desscripscale = maintextscale * 0.7;

      double insetpadding = maintextscale  * 4.0;
      double alrtpadding = maintextscale  * 0.8;
      // double btnpadding = maintextscale  * 0.4;

      // double loadingsize = maintextscale  * 2.8;
      double iconraduis = maintextscale  * 1.4;
      double iconsize = maintextscale  * 1.6;

      double borderraduis = maintextscale  * 0.24;
    
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderraduis),
        ),
        insetPadding: EdgeInsets.symmetric(vertical: alrtpadding,horizontal: alrtpadding),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6)
            ),
            child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: alrtpadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: iconraduis,
                              backgroundColor: const Color.fromARGB(255, 192, 60, 60),
                              child: Icon(Icons.close,color: Colors.white,size:iconsize,),
                            ),
                            SizedBox(height: 20,),
                            Text(whenFail,style: GoogleFonts.itim(fontSize: desscripscale,color: Colors.black,fontWeight: FontWeight.w400),)
                          ],
                      ),
                    )
                ],
              ),
          ),
        )
      );
    }
  );
}