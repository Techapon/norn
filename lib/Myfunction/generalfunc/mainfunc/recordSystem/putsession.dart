import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/checkapnea.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/storevoice.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/recordSystem/limulator/machine.dart';

/// ฟังก์ชั่นเพิ่มข้อมูล sleep session ลงฐานข้อมูล
/// โดยใช้ Batch เพื่อประสิทธิภาพสูง
/// 
/// Parameters:
///   - sleepData: ข้อมูล sleep session ทั้งหมด
///   - sessionId: ชื่อ document session (เช่น "session1")
Future<bool> addSleepSessionData({
  required Map<String, dynamic> sleepData,
  required int sessionId,
}) async {
  try {
    // ดึง email จาก Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      print('ไม่พบผู้ใช้ที่เข้าสู่ระบบ');
      return false;
    }

    final userEmail = user.email;
    print('Adding data for: $userEmail');

    // สร้าง batch
    final batch = FirebaseFirestore.instance.batch();

    final firestore = FirebaseFirestore.instance;
    
    final userQuery = await FirebaseFirestore.instance
      .collection('General user')
      .where("email", isEqualTo: userEmail)
      .get();

    if (userQuery.docs.isEmpty) {
      throw Exception("User not found");
    }

    final sessionDocRef = userQuery.docs.first.reference.collection('sleepsession').doc("session$sessionId");

    // 1. เพิ่มข้อมูล session document (ระดับ root)
    batch.set(sessionDocRef, {
      'id': sleepData['id'],
      'startTime': sleepData['startTime'],
      'endTime': sleepData['endTime'],
      'apnea': sleepData['apnea'],
      'quiet': sleepData['quiet'],
      'lound': sleepData['lound'],
      'verylound': sleepData['verylound'],
      'note': sleepData['note'],
    });

    // 2. เก็บข้อมูล sleepdetail (subcollection)
    final sleepDetail = sleepData['sleepdetail'] as Map<String, dynamic>? ?? {};
    final apneasessionpath = sleepData['apneasessionpath'] as Map<String, dynamic>? ?? {};

    // วนลูปผ่าน hour (hour1, hour2, ...)
    sleepDetail.forEach((hourKey, hourValue) {
      if (hourKey == 'remainer') return; // ข้ามถ้าเป็น remainer

      if (hourValue is Map<String, dynamic>) {
        // สร้าง hour document
        final hourDocRef = sessionDocRef
            .collection('sleepdetail')
            .doc(hourKey); // hour1, hour2, ...

        final minutes = Map<String, dynamic>.from(hourValue)
          ..removeWhere((key, value) => key == 'id');

        // 3. เพิ่ม hour document
        batch.set(hourDocRef, {'id': hourValue['id'] ?? 0});

        // 4. วนลูปผ่าน minute (minute30-1, minute30-2, ...)
        minutes.forEach((minuteKey, minuteValue) {
          if (minuteValue is Map<String, dynamic>) {
            final minuteDocRef = hourDocRef
                .collection('minute')
                .doc(minuteKey); // minute30-1, minute30-2, ...

            // 5. เพิ่ม minute document (only dot list)
            batch.set(minuteDocRef, {
              'id': minuteValue['id'] ?? 0,
              'dot': minuteValue['dot'] ?? [],
            });
          }
        });
      }
    });

    apneasessionpath.forEach((apneasessionKey, apneasessionValue) {
      if (apneasessionValue is Map<String, dynamic>) {
        final apneasessionDocRef = sessionDocRef
            .collection('apneasessionpath')
            .doc(apneasessionKey); // apneasession1, apneasession2, ...

        // 6. เพิ่ม apneasession document
        batch.set(apneasessionDocRef, {
          'id': apneasessionValue['id'] ?? 0,
          'path': apneasessionValue['path'] ?? [],
          'startat' : apneasessionValue['startat'] ?? 0,
          'endat' : apneasessionValue['endat'] ?? 0,
        });
      }
    });

    // ✅ FIXED: Remainer structure - remainer เป็น List<double> โดยตรง
    final remainer = sleepDetail['remainer'] as List<dynamic>? ?? [];
    if (remainer.isNotEmpty) {
      // สร้าง remainer document
      final remainerDocRef = sessionDocRef
          .collection('sleepdetail')
          .doc('remainer');

      // ✅ remainer เป็น List ของ dots โดยตรง
      final remainerDots = List<double>.from(remainer);

      // ✅ Set remainer document with dot as direct field
      batch.set(remainerDocRef, {
        'dot': remainerDots, // ✅ Dots เป็น field ของ remainer โดยตรง
      });
    }

    // Commit batch (execute ทั้งหมดในครั้งเดียว)
    await batch.commit();

    // reset all of valible
    // machine
    buffer.clear();

    // checkapnea
    lastProcessedId = 0;
    consecutiveApneaSeconds = 0;
    ListofshortVoice.clear();
    ListApneabirth.call();
    ListApneasesion.clear();
    apnealistId = 0;

    // store
    sessionTemStore = {};
    
    print('✓ ข้อมูล sleep session เพิ่มสำเร็จ');
    return true;
  } catch (e) {
    print('✗ Error: $e');
    return false;
  }
}