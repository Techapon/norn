import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nornsabai/model/data_model/requestmodel.dart';
import 'dart:async';

// ==================== Caretaker Friend System ====================
class CaretakerFriendSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _caretakerCollection = 'Caretaker';
  final String _generalUserCollection = 'General user';

  // Subcollections
  static const String _requestsSubcollection = 'requests';
  static const String _declinedRequestsSubcollection = 'delinceRequest';
  static const String _incarelistSubcollection = 'incarelist';

  /// ส่ง friend request ไปยัง General User
  Future<Map<String, dynamic>> sendFriendRequest({
    required String caretakerId,
    required String targetUserId,
  }) async {
    try {
      // ตรวจสอบว่า target user มีอยู่จริงหรือไม่
      final targetUserDoc = await _firestore
          .collection(_generalUserCollection)
          .doc(targetUserId)
          .get();

      if (!targetUserDoc.exists) {
        return {
          'success': false,
          'message': 'ไม่พบผู้ใช้ในระบบ',
        };
      }

      // ตรวจสอบว่าส่ง request ไปแล้วหรือยัง
      final existingRequest = await _checkExistingRequest(
        caretakerId,
        targetUserId,
      );
      if (existingRequest) {
        return {
          'success': false,
          'message': 'คุณได้ส่ง request ไปยังผู้ใช้นี้แล้ว',
        };
      }

      // หา ID ล่าสุด
      final latestRequestId = await _getLatestRequestId(
        caretakerId,
        _requestsSubcollection,
      );
      final newRequestId = latestRequestId + 1;

      // สร้างข้อมูล request (เก็บแค่ ID)
      final requestData = {
        'requestId': newRequestId,
        'targetUserId': targetUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // บันทึกใน Caretaker's requests
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .collection(_requestsSubcollection)
          .doc(newRequestId.toString())
          .set(requestData);

      // สร้าง incoming request ใน General User's requests
      final generalUserRequestData = {
        'requestId': newRequestId,
        'fromCaretakerId': caretakerId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_generalUserCollection)
          .doc(targetUserId)
          .collection(_requestsSubcollection)
          .doc(newRequestId.toString())
          .set(generalUserRequestData);

      return {
        'success': true,
        'message': 'ส่ง friend request สำเร็จ',
        'requestId': newRequestId,
      };
    } catch (e) {
      print('Error sending friend request: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }




  /// ยกเลิก request
  Future<Map<String, dynamic>> cancelRequest({
    required String caretakerId,
    required String docId,
    required String targetUserId,
  }) async {
    try {
      // ลบจาก Caretaker's requests
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      // ลบจาก General User's requests
      await _firestore
          .collection(_generalUserCollection)
          .doc(targetUserId)
          .collection(_requestsSubcollection)
          .doc(docId)
          .delete();

      return {
        'success': true,
        'message': 'ยกเลิก request สำเร็จ',
      };
    } catch (e) {
      print('Error canceling request: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  /// ดูรายการที่อยู่ใน requests พร้อมข้อมูล user
  Stream<List<FriendRequestWithUserData>> getRequestsListWithUserData(
      String caretakerId) {
    return _firestore
        .collection(_caretakerCollection)
        .doc(caretakerId)
        .collection(_requestsSubcollection)
        .orderBy('requestId', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<FriendRequestWithUserData> requestsWithData = [];

      for (var doc in snapshot.docs) {
        final request = FriendRequestModel.fromFirestore(doc.id, doc.data());

        // ดึงข้อมูล target user
        UserData? targetUser;
        if (request.targetUserId != null) {
          targetUser = await _getUserData(request.targetUserId!);
        }

        requestsWithData.add(FriendRequestWithUserData(
          request: request,
          targetUser: targetUser,
        ));
      }

      return requestsWithData;
    });
  }

  /// ดูรายการที่อยู่ใน delinceRequest พร้อมข้อมูล user
  Stream<List<FriendRequestWithUserData>> getDeclinedRequestsListWithUserData(
      String caretakerId) {
    return _firestore
        .collection(_caretakerCollection)
        .doc(caretakerId)
        .collection(_declinedRequestsSubcollection)
        .orderBy('requestId', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<FriendRequestWithUserData> requestsWithData = [];

      for (var doc in snapshot.docs) {
        final request = FriendRequestModel.fromFirestore(doc.id, doc.data());

        UserData? targetUser;
        if (request.targetUserId != null) {
          targetUser = await _getUserData(request.targetUserId!);
        }

        requestsWithData.add(FriendRequestWithUserData(
          request: request,
          targetUser: targetUser,
        ));
      }

      return requestsWithData;
    });
  }

  /// ดูรายการที่อยู่ใน incarelist พร้อมข้อมูล user
  /// This stream will update in real-time when isBreathing changes
  Stream<List<FriendRequestWithUserData>> getIncareListWithUserData(
      String caretakerId) {
    // Create a stream controller to manage the combined stream
    late StreamController<List<FriendRequestWithUserData>> controller;
    StreamSubscription? incareSubscription;
    Map<String, StreamSubscription> userSubscriptions = {};

    controller = StreamController<List<FriendRequestWithUserData>>(
      onListen: () {
        // Listen to incarelist changes
        incareSubscription = _firestore
            .collection(_caretakerCollection)
            .doc(caretakerId)
            .collection(_incarelistSubcollection)
            .orderBy('requestId', descending: true)
            .snapshots()
            .listen((incareSnapshot) async {
          // Cancel old user subscriptions
          for (var sub in userSubscriptions.values) {
            await sub.cancel();
          }
          userSubscriptions.clear();

          if (incareSnapshot.docs.isEmpty) {
            controller.add([]);
            return;
          }

          // Get all target user IDs
          final targetUserIds = incareSnapshot.docs
              .map((doc) => doc.data()['targetUserId'] as String?)
              .where((id) => id != null)
              .cast<String>()
              .toSet()
              .toList();

          if (targetUserIds.isEmpty) {
            List<FriendRequestWithUserData> requestsWithData = [];
            for (var doc in incareSnapshot.docs) {
              final request = FriendRequestModel.fromFirestore(doc.id, doc.data());
              requestsWithData.add(FriendRequestWithUserData(
                request: request,
                targetUser: null,
              ));
            }
            controller.add(requestsWithData);
            return;
          }

          // Function to fetch and emit current data
          Future<void> emitCurrentData() async {
            List<FriendRequestWithUserData> requestsWithData = [];

            for (var doc in incareSnapshot.docs) {
              final request = FriendRequestModel.fromFirestore(doc.id, doc.data());

              UserData? targetUser;
              if (request.targetUserId != null) {
                targetUser = await _getUserData(request.targetUserId!);
              }

              requestsWithData.add(FriendRequestWithUserData(
                request: request,
                targetUser: targetUser,
              ));
            }

            print("In care------ ${requestsWithData}");
            if (!controller.isClosed) {
              controller.add(requestsWithData);
            }
          }

          // Emit initial data
          await emitCurrentData();

          // Listen to each user document for changes
          for (var userId in targetUserIds) {
            userSubscriptions[userId] = _firestore
                .collection(_generalUserCollection)
                .doc(userId)
                .snapshots()
                .listen((_) async {
              // When any user document changes, re-emit all data
              await emitCurrentData();
            });
          }
        });
      },
      onCancel: () async {
        await incareSubscription?.cancel();
        for (var sub in userSubscriptions.values) {
          await sub.cancel();
        }
        userSubscriptions.clear();
      },
    );

    return controller.stream;
  }

  /// ยกเลิกการเป็นเพื่อน
  Future<Map<String, dynamic>> removeFriend({
    required String caretakerId,
    required String docId,
    required String targetUserId,
  }) async {
    try {
      await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .collection(_incarelistSubcollection)
          .doc(docId)
          .delete();

      await _firestore
          .collection(_generalUserCollection)
          .doc(targetUserId)
          .collection('caretakerlist')
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

  Stream<int> getCaretakerCount(String caretakerId) {
    return _firestore
        .collection(_caretakerCollection)
        .doc(caretakerId)
        .collection(_incarelistSubcollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getPendingRequestCount(String caretakerId) {
    return _firestore
      .collection(_generalUserCollection)
      .doc(caretakerId)
      .collection(_requestsSubcollection)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
  }


  Future<bool> _checkExistingRequest(
    String caretakerId,
    String targetUserId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_caretakerCollection)
          .doc(caretakerId)
          .collection(_requestsSubcollection)
          .where('targetUserId', isEqualTo: targetUserId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// ดึงข้อมูล General User
  Future<UserData?> _getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(_generalUserCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserData(
        userId: userId,
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        phone: data['phoneNumber'] ?? 0,
        isBreathing: data['isBreathing'],
      );
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}