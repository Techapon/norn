import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';

// ==================== Caretaker Friend System ====================
class CaretakerFriendSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _caretakerCollection = 'Caretaker';
  final String _generalUserCollection = 'General user';

  // Subcollections
  static const String _requestsSubcollection = 'requests';
  static const String _declinedRequestsSubcollection = 'delinceRequest';
  static const String _incarelistSubcollection = 'incarelist';

  /// 1. ฟังก์ชันเพิ่มเพื่อน - ส่ง friend request ไปยัง General User
  Future<Map<String, dynamic>> sendFriendRequest({
    required String caretakerEmail,
    required String targetUserEmail,
  }) async {
    try {
      // ตรวจสอบว่า email มีอยู่ในระบบหรือไม่
      final targetUserId = await _getUserIdByEmail(targetUserEmail);
      if (targetUserId == null) {
        return {
          'success': false,
          'message': 'ไม่พบผู้ใช้ที่มี email นี้',
        };
      }

      // ตรวจสอบว่าส่ง request ไปแล้วหรือยัง
      final existingRequest = await _checkExistingRequest(
        caretakerEmail,
        targetUserEmail,
      );
      if (existingRequest) {
        return {
          'success': false,
          'message': 'request is already exits to ${targetUserEmail}',
        };
      }

      // หา ID ล่าสุด
      final latestRequestId = await _getLatestRequestId(
        caretakerEmail,
        _requestsSubcollection,
      );
      final newRequestId = latestRequestId + 1;
      final docName = 'requestId$newRequestId';

      // สร้างข้อมูล request
      final requestData = {
        'requestId': newRequestId,
        'targetEmail': targetUserEmail,
        // 'targetUserId': targetUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // บันทึกใน Caretaker's requests
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection(_requestsSubcollection)
          .doc(docName)
          .set(requestData);

      // สร้าง incoming request ใน General User's requests
      final generalUserRequestData = {
        'requestId': newRequestId,
        'fromCaretakerEmail': caretakerEmail,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_generalUserCollection)
          .doc(targetUserEmail)
          .collection(_requestsSubcollection)
          .doc(docName)
          .set(generalUserRequestData);

      return {
        'success': true,
        'message': 'Send request success!!',
        'requestId': newRequestId,
      };
    } catch (e) {
      print('Error sending friend request: $e');
      return {
        'success': false,
        'message': 'Error : $e',
      };
    }
  }

  /// 3. ฟังก์ชันยกเลิก request
  Future<Map<String, dynamic>> cancelRequest({
    required String caretakerEmail,
    required String docId,
    required String targetUserEmail,
  }) async {
    try {
      // ลบจาก Caretaker's requests
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      // ลบจาก General User's requests
      await _firestore
          .collection(_generalUserCollection)
          .doc(targetUserEmail)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      return {
        'success': true,
        'message': 'Cancel request $targetUserEmail success',
      };
    } catch (e) {
      print('Error canceling request: $e');
      return {
        'success': false,
        'message': 'Error : $e',
      };
    }
  }

  /// 7. ฟังก์ชันดูรายการที่อยู่ใน requests
  Stream<List<FriendRequestModel>> getRequestsList(String caretakerEmail) {
    return _firestore
        .collection(_caretakerCollection)
        .doc(caretakerEmail)
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
  Stream<List<FriendRequestModel>> getDeclinedRequestsList(String caretakerEmail) {
    return _firestore
        .collection(_caretakerCollection)
        .doc(caretakerEmail)
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

  /// 9. ฟังก์ชันดูรายการที่อยู่ใน incarelist
  Stream<List<FriendRequestModel>> getIncareList(String caretakerEmail) {
    return _firestore
        .collection(_caretakerCollection)
        .doc(caretakerEmail)
        .collection(_incarelistSubcollection)
        // .orderBy('requestId', descending: true)
        .orderBy('incareId', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendRequestModel.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// 10. ฟังก์ชันยกเลิกการเป็นเพื่อน
  Future<Map<String, dynamic>> removeIncare({
    required String caretakerEmail,
    required String docId,
    required String targetUserEmail,
  }) async {
    try {
      // ลบจาก Caretaker's incarelist
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection(_incarelistSubcollection)
          .doc(docId)
          .delete();

      // ลบจาก General User's caretakerlist
      await _firestore
          .collection(_generalUserCollection)
          .doc(targetUserEmail)
          .collection('caretakerlist')
          .doc(docId)
          .delete();

      return {
        'success': true,
        'message': 'Delete freinds success',
      };
    } catch (e) {
      print('Error removing friend: $e');
      return {
        'success': false,
        'message': 'Error : $e',
      };
    }
  }

  // ฟังก์ชันช่วยเหลือ
  Future<int> _getLatestRequestId(String userId, String subcollection) async {
    try {
      final snapshot = await _firestore
          .collection(_caretakerCollection)
          .doc(userId)
          .collection(subcollection)
          .orderBy('requestId', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 0;
      return snapshot.docs.first.data()['requestId'] as int;
    } catch (e) {
      return 0;
    }
  }

  Future<String?> _getUserIdByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection(_generalUserCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _checkExistingRequest(
    String caretakerEmail,
    String targetEmail,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerEmail)
          .collection(_requestsSubcollection)
          .where('targetEmail', isEqualTo: targetEmail)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}


