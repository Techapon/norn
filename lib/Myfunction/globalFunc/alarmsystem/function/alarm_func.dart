
// Update state
import 'package:cloud_firestore/cloud_firestore.dart';
class UserStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String docId;

  UserStatusService({required this.docId});

  Future<void> updateBreathingT() async {
    try {
      await _firestore.collection('General user').doc(docId).update({
        'isBreathing': true,
      });
      print("Successfully updated isBreathing to true for docId: $docId");
    } catch (e) {
      print("Failed to update isBreathing: $e");
      rethrow;
    }
  }

  Future<void> updateBreathingF() async {
    try {
      await _firestore.collection('General user').doc(docId).update({
        'isBreathing': false,
      });
      print("Successfully updated isBreathing to false for docId: $docId");
    } catch (e) {
      print("Failed to update isBreathing: $e");
      rethrow;
    }
  }

  Future<void> updateBreathingNll() async {
    try {
      await _firestore.collection('General user').doc(docId).update({
        'isBreathing': null,
      });
      print("Successfully updated isBreathing to null for docId: $docId");
    } catch (e) {
      print("Failed to update isBreathing: $e");
      rethrow;
    }
  }
}
