import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String docId;
  final int requestId;
  final String? targetEmail;
  // final String? targetUserId;
  final String? fromCaretakerEmail;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? acceptedAt;
  final Timestamp? declinedAt;

  FriendRequestModel({
    required this.docId,
    required this.requestId,
    this.targetEmail,
    // this.targetUserId,
    this.fromCaretakerEmail,
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
      targetEmail: data['targetEmail'],
      // targetUserId: data['targetUserId'],
      fromCaretakerEmail: data['fromCaretakerId'],
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] as Timestamp?,
      acceptedAt: data['acceptedAt'] as Timestamp?,
      declinedAt: data['declinedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'targetEmail': targetEmail,
      // 'targetUserId': targetUserId,
      'fromCaretakerId': fromCaretakerEmail,
      'status': status,
      'createdAt': createdAt,
      'acceptedAt': acceptedAt,
      'declinedAt': declinedAt,
    };
  }

  String get formattedDate {
    final date = createdAt?.toDate();
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'FriendRequestModel(docId: $docId, requestId: $requestId, status: $status)';
  }
}