import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> findAccountByEmail(String email) async {
  try {
   
    final General = await FirebaseFirestore.instance
        .collection('General user')
        .doc(email)
        .get();

    if (General.exists) {
      return {
        'type': 'General',
        'id': General.id,
      };
    }

    
    final Caretaker = await FirebaseFirestore.instance
        .collection('Caretaker')
        .doc(email)
        .get();

    if (Caretaker.exists) {
      return {
        'type': 'Caretaker',
        'id': Caretaker.id,
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
    print('Error finding account by username: $e');
    return false;
  }
}


