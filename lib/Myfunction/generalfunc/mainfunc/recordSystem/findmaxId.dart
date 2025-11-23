import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nornsabai/Myfunction/My_findaccount.dart';

/// ฟังก์ชั่นสำหรับหา id สูงสุดจาก sleepsession subcollection
/// โดยดึงจากผู้ใช้ปัจจุบัน (Firebase Auth)
/// 
/// Returns:
///   - int: ค่า id สูงสุดจากทุก session documents
///   - 0: หากไม่พบ documents ในอพลิเคชั่น
Future<int> getMaxSleepSessionId() async {
  try {
    // ดึง email ของผู้ใช้ปัจจุบันจาก Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      print('Find id form email fail');
      return 0;
    }

    final userEmail = user.email;
    final String? userId = await getUserDocIdByEmail("General user", userEmail!);

    print('Email: $userEmail');

    if(userId == null) {
      print("Error finding account by username");
    }

    // อ้างอิงไปยัง subcollection sleepsession
    final sleepSessionQuery = FirebaseFirestore.instance
        .collection('General user')
        .doc(userId)
        .collection('sleepsession');

    // ดึงข้อมูลทั้งหมดจาก subcollection
    final querySnapshot = await sleepSessionQuery.get();

    if (querySnapshot.docs.isEmpty) {
      print('ไม่พบ documents ใน sleepsession');
      return 0;
    }

    // หา id สูงสุด
    int maxId = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      
      // ตรวจสอบว่ามี field 'detail' และ 'id' หรือไม่
      if (data.containsKey('id')) {
        final id = data['id'];
        
        // แปลงเป็น int หากเป็น String
        int currentId = 0;
        if (id is int) {
          currentId = id;
        } else if (id is String) {
          currentId = int.tryParse(id) ?? 0;
        }
        
        // เปรียบเทียบและอัปเดต maxId
        if (currentId > maxId) {
          maxId = currentId;
        }
        
        print('Document: ${doc.id}, ID: $currentId');
        
      }
    }

    print('Max ID: $maxId');
    return maxId;
  } catch (e) {
    print('Error: $e');
    return 0;
  }
}