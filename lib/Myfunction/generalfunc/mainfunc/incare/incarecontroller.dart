import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';

// ==================== General User Friend System ====================
class GeneralUserFriendSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _caretakerCollection = 'Caretaker';
  final String _generalUserCollection = 'General user';

  static const String _requestsSubcollection = 'requests';
  static const String _declinedRequestsSubcollection = 'delinceRequest';
  static const String _caretakerlistSubcollection = 'caretakerlist';

  /// ยอมรับ friend request
  Future<Map<String, dynamic>> acceptRequest({
    required String generalUserId,
    required String docId,
    required String caretakerId,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      Map<String, dynamic> acceptedData = {
        ...requestData,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserId)
          .collection(_caretakerlistSubcollection)
          .doc(docId)
          .set(acceptedData);

      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserId)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      acceptedData = {
        ...requestData,
        "targetUserId" : generalUserId,
        "fromCaretakerId" : null,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .collection('incarelist')
          .doc(docId)
          .set(acceptedData);

      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      return {
        'success': true,
        'message': 'ยอมรับคำขอสำเร็จ',
      };
    } catch (e) {
      print('Error accepting request: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// ปฏิเสธ friend request
  Future<Map<String, dynamic>> declineRequest({
    required String generalUserId,
    required String docId,
    required String caretakerId,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final declinedData = {
        ...requestData,
        'status': 'declined',
        'declinedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserId)
          .collection(_declinedRequestsSubcollection)
          .doc(docId)
          .set(declinedData);

      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserId)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .collection('delinceRequest')
          .doc(docId)
          .set(declinedData);

      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
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

  /// ดูรายการที่อยู่ใน requests พร้อมข้อมูล caretaker
  Stream<List<FriendRequestWithUserData>> getRequestsListWithUserData(
      String generalUserId) {
    return _firestore
        .collection(_generalUserCollection)
        .doc(generalUserId)
        .collection(_requestsSubcollection)
        .orderBy('requestId', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<FriendRequestWithUserData> requestsWithData = [];

      for (var doc in snapshot.docs) {
        final request = FriendRequestModel.fromFirestore(doc.id, doc.data());

        // ดึงข้อมูล caretaker
        UserData? caretaker;
        if (request.fromCaretakerId != null) {
          caretaker = await _getCaretakerData(request.fromCaretakerId!);
        }

        requestsWithData.add(FriendRequestWithUserData(
          request: request,
          caretaker: caretaker,
        ));
      }

      return requestsWithData;
    });
  }

  /// ดูรายการที่อยู่ใน delinceRequest พร้อมข้อมูล caretaker
  Stream<List<FriendRequestWithUserData>> getDeclinedRequestsListWithUserData(
      String generalUserId) {
    return _firestore
        .collection(_generalUserCollection)
        .doc(generalUserId)
        .collection(_declinedRequestsSubcollection)
        .orderBy('requestId', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<FriendRequestWithUserData> requestsWithData = [];

      for (var doc in snapshot.docs) {
        final request = FriendRequestModel.fromFirestore(doc.id, doc.data());

        UserData? caretaker;
        if (request.fromCaretakerId != null) {
          caretaker = await _getCaretakerData(request.fromCaretakerId!);
        }

        requestsWithData.add(FriendRequestWithUserData(
          request: request,
          caretaker: caretaker,
        ));
      }

      return requestsWithData;
    });
  }

  /// ดูรายการที่อยู่ใน caretakerlist พร้อมข้อมูล caretaker
  Stream<List<FriendRequestWithUserData>> getCaretakerListWithUserData(
      String generalUserId) {
    return _firestore
        .collection(_generalUserCollection)
        .doc(generalUserId)
        .collection(_caretakerlistSubcollection)
        .orderBy('requestId', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<FriendRequestWithUserData> requestsWithData = [];

      for (var doc in snapshot.docs) {
        final request = FriendRequestModel.fromFirestore(doc.id, doc.data());

        UserData? caretaker;
        if (request.fromCaretakerId != null) {
          caretaker = await _getCaretakerData(request.fromCaretakerId!);
        }

        requestsWithData.add(FriendRequestWithUserData(
          request: request,
          caretaker: caretaker,
        ));
      }

      return requestsWithData;
    });
  }

  /// ยกเลิกการเป็นเพื่อน
  Future<Map<String, dynamic>> removeFriend({
    required String generalUserId,
    required String docId,
    required String caretakerId,
  }) async {
    try {
      await _firestore
          .collection(_generalUserCollection)
          .doc(generalUserId)
          .collection(_caretakerlistSubcollection)
          .doc(docId)
          .delete();

      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .collection('incarelist')
          .doc(docId)
          .delete();

      return {
        'success': true,
        'message': 'ยกเลิกการเป็นเพื่อนสำเร็จ',
      };
    } catch (e) {
      print('Error removing friend: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // ============ Helper Functions ============

  /// ดึงข้อมูล Caretaker
  Future<UserData?> _getCaretakerData(String caretakerId) async {
    try {
      final doc = await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserData(
        userId: caretakerId,
        username: data['username'] ?? data['name'] ?? '',
        email: data['email'] ?? '',
      );
    } catch (e) {
      print('Error getting caretaker data: $e');
      return null;
    }
  }
}

