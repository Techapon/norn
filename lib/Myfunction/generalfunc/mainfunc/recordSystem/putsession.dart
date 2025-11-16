import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    
    // Reference ไปยัง session document
    final sessionDocRef = firestore
        .collection('General user')
        .doc(userEmail)
        .collection('sleepsession')
        .doc("session${sessionId}");

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

            // 5. เพิ่ม minute document (only dot list - no separate metadata)
            batch.set(minuteDocRef, {
              'id': minuteValue['id'] ?? 0,
              'dot': minuteValue['dot'] ?? [], // ✅ Only dot list (contains filtered peaks + start/end)
            });
          }
        });
      }
    });

    final remainer = sleepDetail['remainer'] as Map<String, dynamic>? ?? {};
    if (remainer.isNotEmpty) {
      // สร้าง remainer document
      final remainerDocRef = sessionDocRef
          .collection('sleepdetail')
          .doc('remainer');

       List<dynamic> secondsData = [];

      // วนลูปผ่าน minute30, seconds
      remainer.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          if (key.startsWith('minute30-')) {
            // minute30 subcollection
            final minute30DocRef = remainerDocRef
                .collection('minute30')
                .doc(key);

            batch.set(minute30DocRef, {
              'id': value['id'] ?? 0,
              'dot': value['dot'] ?? [], // ✅ Only dot list (contains filtered peaks + start/end)
            });
          } 
          
          else if (key == 'seconds') {
            secondsData = value['dot'] ?? [];
          }
        }
      });

      if (secondsData.isNotEmpty) {
        final secondsDocRef = remainerDocRef
            .collection('seconds')
            .doc('seconds');

        batch.set(secondsDocRef, {
          'dot': secondsData, // ✅ Only dot list (contains filtered peaks + start/end)
        });
      }
      
    }


    // Commit batch (execute ทั้งหมดในครั้งเดียว)
    await batch.commit();

    print('✓ ข้อมูล sleep session เพิ่มสำเร็จ');
    return true;
  } catch (e) {
    print('✗ Error: $e');
    return false;
  }
}
