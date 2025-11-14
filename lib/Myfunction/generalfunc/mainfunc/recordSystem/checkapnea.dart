import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/storevoice.dart';
import 'package:nornsabai/model/data_model/shortVoiceModel.dart';

List<Shortvoicemodel> ListofshortVoice =[];
int threshold = 2;
int consecutiveApneaSeconds = 0;
int lastProcessedId = 0;
bool alerted = false;

void checkApneaContinuity(Shortvoicemodel shortvoice) {
  ListofshortVoice.add(shortvoice);
  ListofshortVoice.sort((a,b) => a.id.compareTo(b.id));

  List<int> processedIds = [];

  for (var shortVoiceItem in ListofshortVoice) {
    // check attribute
    if (shortVoiceItem.id <= lastProcessedId) {
      continue;
    }else if (shortVoiceItem.id -1 != lastProcessedId) {
      continue;
    }else {
      // check type fo Rresult
      if (shortVoiceItem.aiResult == "Apnea") {
        consecutiveApneaSeconds++;
        // print("หายใจติดต่อตอนนี้เป็น ${consecutiveApneaSeconds} ");

        if (consecutiveApneaSeconds >= threshold) {
          // print("!! Stop breathing for ${consecutiveApneaSeconds} seconds !!");
          alerted = true;
        }
      }else {
        consecutiveApneaSeconds = 0;
        alerted = false;
      }

      lastProcessedId = shortVoiceItem.id;

      processedIds.add(shortVoiceItem.id);
      storeAnalyzedVoice(shortVoiceItem);
    }
  }
  ListofshortVoice.removeWhere((value) => processedIds.contains(value.id));
}
