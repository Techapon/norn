import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> findAccountByEmail(String email) async {
  try {
   
    final General = await FirebaseFirestore.instance
        .collection('General user')
        .where("email", isEqualTo: email)
        .get();

    if (General.docs.isNotEmpty) {
      return {
        'type': 'General',
      };
    }

    
    final Caretaker = await FirebaseFirestore.instance
        .collection('Caretaker')
        .where("email", isEqualTo: email)
        .get();

    if (Caretaker.docs.isNotEmpty) {
      return {
        'type': 'Caretaker',
      };
    }

    return null;

  } catch (e) {
    print('Error finding account: $e');
    return null;
  }
}


Future<bool> findNameExits(String username) async {
  try {
    // ตรวจใน General user
    final generalResult = await FirebaseFirestore.instance
        .collection('General user')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (generalResult.docs.isNotEmpty) {
      final doc = generalResult.docs.first;
      print("Find User GE");
      return true;
    }

    // ตรวจใน Caretaker
    final caretakerResult = await FirebaseFirestore.instance
        .collection('Caretaker')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (caretakerResult.docs.isNotEmpty) {
      final doc = caretakerResult.docs.first;
      print("Find User Care");
      return true;
    }

    return false;

  } catch (e) {
    print('erre: $e');
    return false;
  }
}


Future<String?> getUserDocIdByEmail(String whoareu,String email) async {
  final firestore = FirebaseFirestore.instance;

  // ค้นหา document ที่ email ตรงกัน
  final querySnapshot = await firestore
      .collection(whoareu)
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  // ถ้าไม่เจอ document
  if (querySnapshot.docs.isEmpty) return null;

  // คืนค่า docID ตัวแรก
  return querySnapshot.docs.first.id;
}
