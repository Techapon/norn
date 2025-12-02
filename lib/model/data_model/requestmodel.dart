import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nornsabai/Myfunction/formatduration.dart';

// ==================== Model Classes ====================

/// Model สำหรับ Friend Request (เก็บแค่ ID และ metadata)
class FriendRequestModel {
  final String docId;
  final int requestId;
  final String? targetUserId;
  final String? fromCaretakerId;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? acceptedAt;
  final Timestamp? declinedAt;

  FriendRequestModel({
    required this.docId,
    required this.requestId,
    this.targetUserId,
    this.fromCaretakerId,
    required this.status,
    this.createdAt,
    this.acceptedAt,
    this.declinedAt,
  });

  factory FriendRequestModel.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return FriendRequestModel(
      docId: docId,
      requestId: data['requestId'] ?? 0,
      targetUserId: data['targetUserId'],
      fromCaretakerId: data['fromCaretakerId'],
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] as Timestamp?,
      acceptedAt: data['acceptedAt'] as Timestamp?,
      declinedAt: data['declinedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'targetUserId': targetUserId,
      'fromCaretakerId': fromCaretakerId,
      'status': status,
      'createdAt': createdAt,
      'acceptedAt': acceptedAt,
      'declinedAt': declinedAt,
    };
  }

  String get formattedCreate {
    final date = createdAt?.toDate();
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedCreateTime {
    final date = createdAt?.toDate();
    if (date == null) return 'N/A';
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')} $ampm';
  }

  String get formattedAccept {
    final date = acceptedAt?.toDate();
    if (date == null) return 'N/A';
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')} $ampm';
  }

  String get formattedDecline {
    final date = declinedAt?.toDate();
    if (date == null) return 'N/A';
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')} $ampm';
  }

  String get requesttPass {
    final date = createdAt?.toDate();
    final DateTime nowday = DateTime.now();
    if (date == null) return 'N/A';
    final String passed = formatSmallDuration(nowday.difference(date));
    return passed;
  }

  String get acceptPass {
    final date = acceptedAt?.toDate();
    final DateTime nowday = DateTime.now();
    if (date == null) return 'N/A';
    final String passed = formatSmallDuration(nowday.difference(date));
    return passed;
  }

  String get declinePass {
    final date = declinedAt?.toDate();
    final DateTime nowday = DateTime.now();
    if (date == null) return 'N/A';
    final String passed = formatSmallDuration(nowday.difference(date));
    return passed;
  }



  @override
  String toString() {
    return 'FriendRequestModel(docId: $docId, requestId: $requestId, status: $status)';
  }
}

/// Model สำหรับข้อมูล User (จาก user document)
class UserData {
  final String userId;
  final String username;
  final String email;
  final int phone;
  final bool? isBreathing;

  UserData({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    this.isBreathing,
  });

  @override
  String toString() {
    return 'UserData(userId: $userId, username: $username, email: $email, isBreathing: $isBreathing)';
  }
}

/// Model รวม Request + User Data
class FriendRequestWithUserData {
  final FriendRequestModel request;
  final UserData? targetUser; // สำหรับ Caretaker ใช้ดูข้อมูล General User
  final UserData? caretaker; // สำหรับ General User ใช้ดูข้อมูล Caretaker

  FriendRequestWithUserData({
    required this.request,
    this.targetUser,
    this.caretaker,
  });

  @override
  String toString() {
    return 'FriendRequestWithUserData(request: $request, targetUser: $targetUser, caretaker: $caretaker)';
  }
}

