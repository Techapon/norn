import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/storevoice.dart';
import 'package:nornsabai/Myfunction/globalFunc/alarmsystem/screen/alarm_ge.dart';
import 'package:nornsabai/genaraluser/general_main.dart';
import 'package:nornsabai/model/data_model/shortVoiceModel.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

//  shoervoice part
List<Shortvoicemodel> ListofshortVoice =[];
int threshold = 5;
int consecutiveApneaSeconds = 0;
int lastProcessedId = 0;
bool alerted = false;


// file path part
List<Map<String,dynamic>> ListApneabirth =[];
List<Map<String,dynamic>> ListApneasesion =[];

int apnealistId = 0;

bool apneacritical = false;

void checkApneaContinuity(Shortvoicemodel shortvoice) {

  print("in appnea progressing ${shortvoice.shortValue}");
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
      print("init 2");
      // check type of Rresult
      if (shortVoiceItem.aianalyzereault == "Apnea") {
        consecutiveApneaSeconds++;

        print("หายใจติดต่อตอนนี้เป็น ${consecutiveApneaSeconds} ");

        ListApneabirth.add({
          "id": shortVoiceItem.id,
          "path": shortVoiceItem.filePath,
          "start": shortVoiceItem.shortstart,
          "end": shortVoiceItem.shortend,
        });

        if (consecutiveApneaSeconds >= threshold) {

          print("!! Stop breathing for ${consecutiveApneaSeconds} seconds !!");

          AlarmApnea();
          
          // update breath status
          updatebreath.updateBreathingF();
          

          apneacritical = true;

          alerted = true;
        }
      }else {
        consecutiveApneaSeconds = 0;

        updatebreath.updateBreathingT();

        deleteAudioFile(shortVoiceItem.filePath!);

        if (apneacritical) {
          storeApneaSession(ListApneabirth);
        }
        ListApneabirth.clear();
        apneacritical = false;
        
        alerted = false;
      }

      lastProcessedId = shortVoiceItem.id;

      processedIds.add(shortVoiceItem.id);
      print("Checked!! short voice id : ${shortVoiceItem.id} | value : ${shortVoiceItem.shortValue}");
      storeAnalyzedVoice(shortVoiceItem);
    }
  }
  ListofshortVoice.removeWhere((value) => processedIds.contains(value.id));
}


storeApneaSession(List<Map<String,dynamic>> ListApneabirth) async {
  apnealistId++;

  List<String> paths = [];

  for (var apneaItem in ListApneabirth) {
    paths.add(apneaItem["path"]);
  }

  Directory dir = await getApplicationDocumentsDirectory();
  String outputPath = "${dir.path}/apnea_${apnealistId}_${DateTime.now().millisecondsSinceEpoch}.wav";

  bool maergeApneapath =  await mergeWavFiles(paths, outputPath);

  if (maergeApneapath) {
    var apneasession = {
      "id": apnealistId,
      "path": outputPath,
      "start": ListApneabirth.first["start"],
      "end": ListApneabirth.last["end"],
    };
    ListApneasesion.add(apneasession);

    if (sessionTemStore["apneasessionpath"] is Map) {
      sessionTemStore["apneasessionpath"]["apneasesion$apnealistId"] = apneasession;
    }
  }else {
    print("merge error");
  }
}

Future<bool> mergeWavFiles(List<String> paths, String outputPath) async {
  List<int> mergedBytes = [];

  for (var i = 0; i < paths.length; i++) {
    var file = File(paths[i]);
    var bytes = await file.readAsBytes();

    if (i == 0) {
      // เก็บ header ของไฟล์แรก
      mergedBytes.addAll(bytes);
    } else {
      // skip header ของไฟล์อื่น (44 bytes)
      mergedBytes.addAll(bytes.sublist(44));
    }
  }

  // ปรับ header ของไฟล์แรก (ChunkSize, Subchunk2Size) ที่ index 4 และ 40
  int dataSize = mergedBytes.length - 44;
  mergedBytes[4] = (dataSize + 36) & 0xFF;
  mergedBytes[5] = ((dataSize + 36) >> 8) & 0xFF;
  mergedBytes[6] = ((dataSize + 36) >> 16) & 0xFF;
  mergedBytes[7] = ((dataSize + 36) >> 24) & 0xFF;

  mergedBytes[40] = dataSize & 0xFF;
  mergedBytes[41] = (dataSize >> 8) & 0xFF;
  mergedBytes[42] = (dataSize >> 16) & 0xFF;
  mergedBytes[43] = (dataSize >> 24) & 0xFF;

  try {
    await File(outputPath).writeAsBytes(mergedBytes);
    return true;
  }catch(e){
    return false;
  }
}

Future<void> deleteAudioFile(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print("delete success:");
    } else {
      print("file not found : $path");
    }
  } catch (e) {
    print("has error in file delete progress : $e");
  }
}
