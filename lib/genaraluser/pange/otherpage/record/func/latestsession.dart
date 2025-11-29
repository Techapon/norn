import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model class to represent a session's field data
class LatestSessionData {
  final int? id;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? apnea;
  final int? quiet;
  final int? lound;
  final int? verylound;
  final String? note;
  final Map<String, dynamic>? apneasessionpath;
  final Map<String, dynamic>? sleepdetail;

  LatestSessionData({
    this.id,
    this.startTime,
    this.endTime,
    this.apnea,
    this.quiet,
    this.lound,
    this.verylound,
    this.note,
    this.apneasessionpath,
    this.sleepdetail,
  });

  /// Create LatestSessionData from Firestore document
  factory LatestSessionData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LatestSessionData(
      id: data['id'] as int?,
      startTime: (data['startTime'] as Timestamp?)?.toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      apnea: data['apnea'] as int?,
      quiet: data['quiet'] as int?,
      lound: data['lound'] as int?,
      verylound: data['verylound'] as int?,
      note: data['note'] as String?,
      apneasessionpath: data['apneasessionpath'] as Map<String, dynamic>?,
      sleepdetail: data['sleepdetail'] as Map<String, dynamic>?,
    );
  }

  /// Calculate total sleep time in seconds
  int get totalSleepTime {
    return (apnea ?? 0) + (quiet ?? 0) + (lound ?? 0) + (verylound ?? 0);
  }

  /// Calculate total sleep time in minutes
  double get totalSleepTimeMinutes {
    return totalSleepTime / 60;
  }

  /// Calculate total sleep time in hours
  double get totalSleepTimeHours {
    return totalSleepTime / 3600;
  }

  /// Calculate snore score (lound + verylound) in seconds
  int get snoreScore {
    return (lound ?? 0) + (verylound ?? 0);
  }

  /// Calculate snore percentage
  double get snorePercent {
    if (totalSleepTime == 0) return 0;
    return (snoreScore / totalSleepTime) * 100;
  }

  /// Format sleep duration as "HH:MM:SS"
  String get formattedDuration {
    int hours = totalSleepTime ~/ 3600;
    int minutes = (totalSleepTime % 3600) ~/ 60;
    int seconds = totalSleepTime % 60;

    String twoDigits(int value) => value.toString().padLeft(2, "0");

    return "${twoDigits(hours)}:${twoDigits(minutes)}";
  }

  @override
  String toString() {
    return 'LatestSessionData(id: $id, startTime: $startTime, endTime: $endTime, '
        'apnea: $apnea, quiet: $quiet, lound: $lound, verylound: $verylound, '
        'totalSleepTime: ${formattedDuration})';
  }
}

/// Function to get the latest session field data
/// Returns LatestSessionData object or null if no session found
Future<LatestSessionData?> getLatestSession() async {
  try {
    // Get current user email
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      print('Error: No authenticated user found');
      return null;
    }

    // Query Firestore for the latest session
    final snapshot = await FirebaseFirestore.instance
        .collection('General user')
        .doc(user.email)
        .collection('sleepsession')
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    // Check if any session exists
    if (snapshot.docs.isEmpty) {
      print('No session found');
      return null;
    }

    // Get the first (latest) document
    final latestDoc = snapshot.docs.first;
    
    // Convert to LatestSessionData object
    final sessionData = LatestSessionData.fromFirestore(latestDoc);
    
    print('✓ Latest session loaded: ${sessionData.toString()}');
    
    return sessionData;

  } catch (e) {
    print('Error fetching latest session: $e');
    return null;
  }
}

/// Function to get the latest session by user document ID
/// Useful when you need to fetch session for a specific user
Future<LatestSessionData?> getLatestSessionByUserId(String userDocId) async {
  try {
    // Query Firestore for the latest session
    final snapshot = await FirebaseFirestore.instance
        .collection('General user')
        .doc(userDocId)
        .collection('sleepsession')
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    // Check if any session exists
    if (snapshot.docs.isEmpty) {
      print('No session found for user: $userDocId');
      return null;
    }

    // Get the first (latest) document
    final latestDoc = snapshot.docs.first;
    
    // Convert to LatestSessionData object
    final sessionData = LatestSessionData.fromFirestore(latestDoc);
    
    print('✓ Latest session loaded for $userDocId: ${sessionData.toString()}');
    
    return sessionData;

  } catch (e) {
    print('Error fetching latest session for user $userDocId: $e');
    return null;
  }
}
