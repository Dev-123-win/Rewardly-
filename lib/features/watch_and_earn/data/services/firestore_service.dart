import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getWatchAndEarnData(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserWatchAndEarnData(
    String userId,
    int points,
    int dailyAdCount,
    Timestamp lastAdWatchedTimestamp,
  ) async {
    await _db.collection('users').doc(userId).set(
      {
        'points': points,
        'dailyAdCount': dailyAdCount,
        'lastAdWatchedTimestamp': lastAdWatchedTimestamp,
      },
      SetOptions(merge: true),
    );
  }
}
