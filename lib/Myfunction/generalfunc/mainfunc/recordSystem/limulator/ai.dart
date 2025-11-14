import 'dart:math';

import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/checkapnea.dart';
import 'package:nornsabai/model/data_model/shortVoiceModel.dart';

Future<void> AiAnalyzeSound(Shortvoicemodel shortvoice) async{
  double voiceValue = shortvoice.shortValue;

  if (shortvoice.ended == false) {
    // print("Ai ----");
    // print("id ---- ${shortvoice.id}");
    // print("value ---- ${shortvoice.shortValue}");
    // print("ended ---- ${shortvoice.ended}");
    // Ai processing simulator
    var random = Random();
    int processTime = ((random.nextDouble() * (3.0-1.0)) + 1.0).round();
    // int processTime = ((random.nextDouble() * (3.0-1.0)) + 1.0 *1000).round();

    // print("Id : ${shortvoice.id} wating ${processTime} millisecond \n");
    await Future.delayed(Duration(milliseconds: processTime));
    
    if (0 <= voiceValue && voiceValue <= 25) {
      shortvoice.aiResult = "Apnea";
    }else if (25 < voiceValue && voiceValue <= 50) {
      shortvoice.aiResult = "Quiet";
    }else if (50 < voiceValue && voiceValue <= 75) {
      shortvoice.aiResult = "Lound";
    }else if (75 < voiceValue && voiceValue <= 100) {
      shortvoice.aiResult = "Very Lound";
    }

    // print("processed id : ${shortvoice.id}");

    // print("Processing success Id: ${shortvoice.id} ** value ${shortvoice.shortValue} ** result : ${shortvoice.aiResult}");
    checkApneaContinuity(shortvoice);
  }else {
    checkApneaContinuity(shortvoice);
    // print("skip ${shortvoice.id}  ${shortvoice.shortValue} the ai");
  }
}


