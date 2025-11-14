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