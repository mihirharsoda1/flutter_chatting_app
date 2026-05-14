import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save a message when user sends it
  Future<void> saveMessage({
    required String senderId,
    required String receiverId,
    required String text,
    required String type, // 'text', 'image', etc.
  }) async {
    await _firestore.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'isRead': false,
    });
  }

  // Save a call log when a call ends
  Future<void> saveCallLog({
    required String callerId,
    required String calleeId,
    required int duration, // seconds
    required String type, // 'audio' or 'video'
    required String status, // 'completed', 'missed', 'rejected'
  }) async {
    final startTime = DateTime.now().millisecondsSinceEpoch - (duration * 1000);
    final endTime = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('call_logs').add({
      'callerId': callerId,
      'calleeId': calleeId,
      'duration': duration,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'status': status,
    });
  }

  // Optional: fetch call history for a user
  Stream<QuerySnapshot> getCallLogsForUser(String userId) {
    return _firestore
        .collection('call_logs')
        .where('callerId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots();
  }
}
