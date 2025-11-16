
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/findmaxId.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/advanced_peak_detection.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/putsession.dart';
import 'package:nornsabai/model/data_model/shortVoiceModel.dart';


Map<String,dynamic> sessionTemStore = createSession();
// sessionTemStore["sleepdetail"] = <String, dynamic>{};


List<double> listOfAllShort = [];

int apnea = 0;
int quiet = 0;
int lound = 0;
int verylound = 0;

int totalsession = 0;

int peakcount = 0;

void storeAnalyzedVoice(Shortvoicemodel shortVoice) async{

  if (shortVoice.ended == false) {
    totalsession++;

    switch (shortVoice.aiResult) {
      case "Apnea" :
        apnea++;
        break;
      case "Quiet" :
        quiet++;
        break;
      case "Lound" :
        lound++;
        break;
      case "Very Lound" :
        verylound++;
        break;
      default :
        break;
    }

    listOfAllShort.add(shortVoice.shortValue);
    print("Stored!! short voice id : ${shortVoice.id} | type : ${shortVoice.shortValue}" );

  }else {
    print("End at : ${shortVoice.id} \n ${shortVoice.shortValue} \n ${shortVoice.aiResult} \n ${shortVoice.ended}");

    int maxId = await getMaxSleepSessionId();

    sessionTemStore["id"] = maxId+1;

    sessionTemStore["apnea"] = apnea;
    sessionTemStore["quiet"] = quiet;
    sessionTemStore["lound"] = lound;
    sessionTemStore["verylound"] = verylound;

    // Format main data - 30-minute intervals (1800 seconds)
    int hourscount = 0;    
    while (listOfAllShort.length >= 3600) {
      hourscount++;
      sessionTemStore["sleepdetail"]["hour${hourscount}"] = <String, dynamic>{
        "id" : hourscount,
      };

        int minutecount = 0;
        // ✅ Process 30-minute chunks (2 per hour: 0-30min, 30-60min)
        while (listOfAllShort.length >= 1800) {
          if (minutecount == 2) {
            minutecount = 0;
            break;
          };
          minutecount++;

          // ✅ Very strict peak detection (max 3 peaks per 30-min interval) - only extremely significant peaks
          final chunk = listOfAllShort.sublist(0, 1800 + 1);
          final peakResult = detectPeaksAdvanced(
            chunk,
            windowSize: 10, // ✅ Larger window for better context
            sdMultiplier: 10.0, // ✅ 2.5x increase (4.0 → 10.0) - requires very strong deviation
            minProminence: 20.0, // ✅ 2.5x increase (8.0 → 20.0) - requires extremely high prominence
            slopeThreshold: 3.75, // ✅ 2.5x increase (1.5 → 3.75) - requires very steep changes
            adaptiveThreshold: true,
            maxPeaksPerInterval: 3, // ✅ Reduced to 3 - only top 3 most significant peaks
          );

          // Build dot list: ensure first and last are included
          // ✅ Only store filtered values (top 3 peaks + start/end) in dot list
          List<double> dotList = List.from(peakResult.values);
          if (dotList.isEmpty || dotList.first != chunk.first) {
            dotList.insert(0, chunk.first);
          }
          if (dotList.isEmpty || dotList.last != chunk.last) {
            dotList.add(chunk.last);
          }

          peakcount += dotList.length;

          // ✅ Store only dot list (no separate metadata to save database space)
          sessionTemStore["sleepdetail"]["hour${hourscount}"]["minute30-${minutecount}"] = {
            "id": minutecount,
            "dot": dotList, // ✅ Contains: top 3 most significant peaks + start/end values only
          };
          listOfAllShort.removeRange(0, 1800 + 1);
        }
    }

    formatRemainder();

    print("TOTAL : ${totalsession}");
    print("All dots : ${peakcount}");
    print("----------------------------------");
    
    // String prettyJson = (JsonEncoder.withIndent(' ').convert(sessionTemStore)).toString();
    // debugPrint(prettyJson, wrapWidth: 1024);

    // reset valible
    apnea = 0;
    quiet = 0;
    lound = 0;
    verylound = 0;
    totalsession = 0;
    peakcount = 0;

    final success = await addSleepSessionData(
      sleepData: sessionTemStore,
      sessionId: sessionTemStore["id"],
    );
    
    if (success) {
      print('✓ Session data saved successfully');
    } else {
      print('✗ Failed to save session data');
    }
  }
}


// create session
Map<String,dynamic> createSession() {
  Map<String, dynamic> sessionTemStore = {
    "id": null,
    "startTime": null,
    "endTime": null,
    "apnea": null,
    "quiet": null,
    "lound": null,
    "verylound": null,
    "note": "",
    "sleepdetail": <String, dynamic>{
      "remainer": <String, dynamic>{}
    }
  };
  return sessionTemStore;
}

// Format remainer function - 30-minute intervals
void formatRemainder() {
  int minute30Count = 0;
  int remainerID = 0;

  // ✅ Process remainer in 30-minute chunks (1800 seconds)
  while (listOfAllShort.length >= 1800) {
    remainerID++;
    final chunk = listOfAllShort.sublist(0, 1800 + 1);
    
    // ✅ Very strict peak detection (max 3 peaks per 30-min interval) - only extremely significant peaks
    final peakResult = detectPeaksAdvanced(
      chunk,
      windowSize: 10, // ✅ Larger window for better context
      sdMultiplier: 10.0, // ✅ 2.5x increase (4.0 → 10.0) - requires very strong deviation
      minProminence: 20.0, // ✅ 2.5x increase (8.0 → 20.0) - requires extremely high prominence
      slopeThreshold: 3.75, // ✅ 2.5x increase (1.5 → 3.75) - requires very steep changes
      adaptiveThreshold: true,
      maxPeaksPerInterval: 3, // ✅ Reduced to 3 - only top 3 most significant peaks
    );

    List<double> remianerMinute30 = List.from(peakResult.values);
    if (remianerMinute30.isEmpty || remianerMinute30.first != chunk.first) {
      remianerMinute30.insert(0, chunk.first);
    }
    if (remianerMinute30.isEmpty || remianerMinute30.last != chunk.last) {
      remianerMinute30.add(chunk.last);
    }

    peakcount += remianerMinute30.length;

    minute30Count++;
    // ✅ Store only dot list (no separate metadata to save database space)
    sessionTemStore["sleepdetail"]["remainer"]["minute30-${minute30Count}"] = {
      "id": remainerID,
      "dot": remianerMinute30, // ✅ Contains: top 5 most significant peaks + start/end values only
    };
    listOfAllShort.removeRange(0, 1800 + 1);
  }

  if (listOfAllShort.length > 0) {
    final chunk = listOfAllShort.sublist(0, listOfAllShort.length);
    
    // ✅ Very strict peak detection for remaining seconds - only extremely significant peaks
    final peakResult = detectPeaksAdvanced(
      chunk,
      windowSize: 10, // ✅ Larger window for better context
      sdMultiplier: 10.0, // ✅ 2.5x increase (4.0 → 10.0) - requires very strong deviation
      minProminence: 20.0, // ✅ 2.5x increase (8.0 → 20.0) - requires extremely high prominence
      slopeThreshold: 3.75, // ✅ 2.5x increase (1.5 → 3.75) - requires very steep changes
      adaptiveThreshold: true,
      maxPeaksPerInterval: 3, // ✅ Only top 3 most significant peaks
    );

    List<double> remianerSecond = List.from(peakResult.values);
    if (remianerSecond.isEmpty || remianerSecond.first != chunk.first) {
      remianerSecond.insert(0, chunk.first);
    }
    if (remianerSecond.isEmpty || remianerSecond.last != chunk.last) {
      remianerSecond.add(chunk.last);
    }

    peakcount += remianerSecond.length;

    // ✅ Store only dot list (no separate metadata to save database space)
    sessionTemStore["sleepdetail"]["remainer"]["seconds"] = {
      "dot": remianerSecond, // ✅ Contains: top 5 most significant peaks + start/end values only
    };
    listOfAllShort.clear();
  }
}



