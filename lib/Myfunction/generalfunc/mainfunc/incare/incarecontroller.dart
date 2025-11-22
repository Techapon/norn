import 'package:nornsabai/model/data_model/requestmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralUserFriendSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _caretakerCollection = 'Caretaker';
  final String _generalUserCollection = 'General user';

  // Subcollections
  static const String _requestsSubcollection = 'requests';
  static const String _declinedRequestsSubcollection = 'delinceRequest';
  static const String _caretakerlistSubcollection = 'caretakerlist';

  /// ฟังก์ชันตอบรับ friend request (Accept)
  Future<Map<String, dynamic>> acceptRequest({
    required String generalUserEmail,
    required String docId,
    required String caretakerEmail,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      // อัปเดตสถานะและย้ายไป caretakerlist ของ General User
      final acceptedData = {
        ...requestData,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserEmail)
          .collection(_caretakerlistSubcollection)
          .doc(docId)
          .set(acceptedData);

      // ลบจาก requests ของ General User
      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserEmail)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      // ย้ายไป incarelist ของ Caretaker
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection('incarelist')
          .doc(docId)
          .set(acceptedData);

      // ลบจาก requests ของ Caretaker
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      return {
        'success': true,
        'message': 'Appect success',
      };
    } catch (e) {
      print('Error accepting request: $e');
      return {
        'success': false,
        'message': 'Error : $e',
      };
    }
  }

  /// ฟังก์ชันปฏิเสธ friend request (Decline)
  Future<Map<String, dynamic>> declineRequest({
    required String generalUserEmail,
    required String docId,
    required String caretakerEmail,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      // อัปเดตสถานะและย้ายไป delinceRequest ของ General User
      final declinedData = {
        ...requestData,
        'status': 'declined',
        'declinedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserEmail)
          .collection(_declinedRequestsSubcollection)
          .doc(docId)
          .set(declinedData);

      // ลบจาก requests ของ General User
      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserEmail)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      // ย้ายไป delinceRequest ของ Caretaker
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection('delinceRequest')
          .doc(docId)
          .set(declinedData);

      // ลบจาก requests ของ Caretaker
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      return {
        'success': true,
        'message': 'ปฏิเสธคำขอสำเร็จ',
      };
    } catch (e) {
      print('Error declining request: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// 7. ฟังก์ชันดูรายการที่อยู่ใน requests
  Stream<List<FriendRequestModel>> getRequestsList(String generalUserEmail) {
    return _firestore
        .collection(_generalUserCollection)
        .doc(generalUserEmail)
        .collection(_requestsSubcollection)
        .orderBy('requestId', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendRequestModel.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// 8. ฟังก์ชันดูรายการที่อยู่ใน delinceRequest
  Stream<List<FriendRequestModel>> getDeclinedRequestsList(String generalUserEmail) {
    return _firestore
        .collection(_generalUserCollection)
        .doc(generalUserEmail)
        .collection(_declinedRequestsSubcollection)
        // .orderBy('requestId', descending: true)
        .orderBy('declineId', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendRequestModel.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// 9. ฟังก์ชันดูรายการที่อยู่ใน caretakerlist
  Stream<List<FriendRequestModel>> getCaretakerList(String generalUserEmail) {
    return _firestore
        .collection(_generalUserCollection)
        .doc(generalUserEmail)
        .collection(_caretakerlistSubcollection)
        // .orderBy('requestId', descending: true)
        .orderBy('caretakerId', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendRequestModel.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// 10. ฟังก์ชันยกเลิกการเป็นเพื่อน
  Future<Map<String, dynamic>> removeFriend({
    required String generalUserEmail,
    required String docId,
    required String caretakerEmail,
  }) async {
    try {
      // ลบจาก General User's caretakerlist
      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserEmail)
          .collection(_caretakerlistSubcollection)
          .doc(docId)
          .delete();

      // ลบจาก Caretaker's incarelist
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection('incarelist')
          .doc(docId)
          .delete();

      return {
        'success': true,
        'message': 'Calcel freinds success',
      };
    } catch (e) {
      print('Error removing friend: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}