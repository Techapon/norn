
import 'dart:convert';

import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/findmaxId.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/findpeakdata.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/putsession.dart';
import 'package:nornsabai/model/data_model/shortVoiceModel.dart';
import 'package:flutter/material.dart';


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

    // Format main data 
    int hourscount = 0;    
    while (listOfAllShort.length >= 3600) {
      hourscount++;
      sessionTemStore["sleepdetail"]["hour${hourscount}"] = <String, dynamic>{
        "id" : hourscount,
      };

      int minutecount = 0;
      while (listOfAllShort.length >= 600) {
        if (minutecount == 6) {
          minutecount = 0;
          break;
        };
        minutecount++;

        List<double> dotList = analyzePeakValue(listOfAllShort.sublist(0,600+1));

        dotList.insert(0, listOfAllShort.first);
        dotList.add(listOfAllShort.last);

        peakcount += dotList.length;

        sessionTemStore["sleepdetail"]["hour${hourscount}"]["minute10-${minutecount}"] = {
          "id" : minutecount,
          "dot" : dotList // put peak value here
        };
        listOfAllShort.removeRange(0,600+1);
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

    bool success = await addSleepSessionData(
      sleepData: sessionTemStore,
      sessionId: sessionTemStore["id"],
    );
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

// Format remainer function
void formatRemainder() {
  int minute10Count = 0;
  // int minuteCount = 0;

  int remainerID = 0;

  while (listOfAllShort.length >= 600) {
    remainerID++;
    List<double> remianerMinute10 = analyzePeakValue(listOfAllShort.sublist(0,600+1));
    peakcount += remianerMinute10.length;

    remianerMinute10.insert(0, listOfAllShort.first);
    remianerMinute10.add(listOfAllShort.last);

    minute10Count++;
    sessionTemStore["sleepdetail"]["remainer"]["minute10-${minute10Count}"] = {
      "id": remainerID,
      "dot":  remianerMinute10 //listOfAllShort.sublist(0, 600)
    };
    listOfAllShort.removeRange(0, 600+1);
  }

  // while (listOfAllShort.length >= 60) {
  //   remainerID++;
  //   List<double> remianerMinute = analyzePeakValue(listOfAllShort.sublist(0,60+1));  
  //   minuteCount++;
  //   sessionTemStore["sleepdetail"]["remainer"]["minute-${minuteCount}"] = {
  //     "id": remainerID,
  //     "dot": remianerMinute  //listOfAllShort.sublist(0, 60)
  //   };
  //   listOfAllShort.removeRange(0, 60+1);
  // }

  if (listOfAllShort.length > 0) {
    List<double> remianerSecond = analyzePeakValue(listOfAllShort.sublist(0,listOfAllShort.length));
    peakcount += remianerSecond.length;

    remianerSecond.insert(0, listOfAllShort.first);
    remianerSecond.add(listOfAllShort.last);

    sessionTemStore["sleepdetail"]["remainer"]["seconds"] = {
      "dot": remianerSecond
    };
    listOfAllShort.clear();
  }
}



