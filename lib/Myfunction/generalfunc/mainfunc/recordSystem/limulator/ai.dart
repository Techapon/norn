import 'dart:math';

import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/checkapnea.dart';
import 'package:nornsabai/model/data_model/shortVoiceModel.dart';

Future<void> AiAnalyzeSound(Shortvoicemodel shortvoice) async{
  double voiceValue = shortvoice.shortValue;

  if (shortvoice.ended == false) {
    var random = Random();
    int processTime = ((random.nextDouble() * (3.0-1.0)) + 1.0).round();

    await Future.delayed(Duration(milliseconds: processTime));
    
    if (0 <= voiceValue && voiceValue <= 25) {
      shortvoice.aianalyzereault = "Apnea";
      shortvoice.aivoicevolume = shortvoice.shortValue;

    }else if (25 < voiceValue && voiceValue <= 50) {
      shortvoice.aianalyzereault = "Quiet";
      shortvoice.aivoicevolume = shortvoice.shortValue;

    }else if (50 < voiceValue && voiceValue <= 75) {
      shortvoice.aianalyzereault = "Lound";
      shortvoice.aivoicevolume = shortvoice.shortValue;

    }else if (75 < voiceValue && voiceValue <= 100) {
      shortvoice.aianalyzereault = "Very Lound";
      shortvoice.aivoicevolume = shortvoice.shortValue;

    }

    checkApneaContinuity(shortvoice);
  }else {
    checkApneaContinuity(shortvoice);
  }
}





