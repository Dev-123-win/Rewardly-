import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final int points;
  final int streak;
  final DateTime? lastCheckIn;
  final String tier;
  final int referralsCount;

  AppUser({
    required this.uid,
    required this.email,
    this.points = 0,
    this.streak = 0,
    this.lastCheckIn,
    this.tier = 'Bronze',
    this.referralsCount = 0,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      lastCheckIn: (data['lastCheckIn'] as Timestamp?)?.toDate(),
      tier: data['tier'] ?? 'Bronze',
      referralsCount: data['referralsCount'] ?? 0,
    );
  }

  AppUser copyWith({
    int? points,
    int? streak,
    DateTime? lastCheckIn,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      tier: tier,
      referralsCount: referralsCount,
    );
  }
}
