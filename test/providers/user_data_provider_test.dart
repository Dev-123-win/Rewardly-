import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:rewardly/providers/user_data_provider.dart';
import 'package:rewardly/models/user_tier.dart';
import 'package:rewardly/models/achievement.dart';

// Mocks
class MockFirebaseAuth extends Mock implements MockFirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FakeFirebaseFirestore {}

void main() {
  group('UserDataProvider Tests', () {
    late UserDataProvider userDataProvider;
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    const String userId = 'test_user';

    setUp(() {
      mockUser = MockUser(uid: userId);
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      fakeFirestore = FakeFirebaseFirestore();

      // Pre-populate user data
      fakeFirestore.collection('users').doc(userId).set({
        'points': 100,
        'tier': UserTier.bronze.index,
        'dailyStreak': 1,
        'lastAdWatchedTimestamp': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        'adsWatchedToday': 0,
        'unlockedAchievements': [],
      });

      userDataProvider = UserDataProvider(
        auth: mockAuth,
        firestore: fakeFirestore,
      );
      // Manually trigger the listener after setup
      userDataProvider.listenToUserData();
    });

    test('Initial data loads correctly', () async {
      // Allow the stream to emit
      await Future.delayed(Duration.zero);
      expect(userDataProvider.points, 100);
      expect(userDataProvider.userData?['tier'], UserTier.bronze.index);
      expect(userDataProvider.isLoading, isFalse);
    });

    test('handleReward awards points and updates ad count', () async {
      final result = await userDataProvider.handleReward(50, isGameReward: false);

      expect(result['success'], isTrue);
      expect(userDataProvider.points, 150);
      expect(userDataProvider.userData?['adsWatchedToday'], 1);
    });

    test('handleReward for game reward awards points but does not update ad count', () async {
      final result = await userDataProvider.handleReward(30, isGameReward: true);

      expect(result['success'], isTrue);
      expect(userDataProvider.points, 130);
      expect(userDataProvider.userData?['adsWatchedToday'], 0, reason: "Game rewards should not count as watched ads");
    });

    test('handleReward respects daily ad limit', () async {
       // Set ads watched to the limit
      await fakeFirestore.collection('users').doc(userId).update({'adsWatchedToday': 10});
      userDataProvider.listenToUserData(); // Re-listen to get updated data
      await Future.delayed(Duration.zero);

      final result = await userDataProvider.handleReward(50, isGameReward: false);

      expect(result['success'], isFalse);
      expect(result['message'], 'You have reached your daily ad limit.');
      expect(userDataProvider.points, 100); // Points should not change
    });
    
    test('handleReward completes daily goal and increases streak', () async {
      // Simulate watching 9 ads already
      await fakeFirestore.collection('users').doc(userId).update({
          'adsWatchedToday': 9,
          // Ensure last ad was yesterday to allow for streak increase
          'lastAdWatchedTimestamp': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      });
      userDataProvider.listenToUserData();
      await Future.delayed(Duration.zero);

      final result = await userDataProvider.handleReward(50, isGameReward: false);

      expect(result['success'], isTrue);
      expect(result['dailyGoalCompleted'], isTrue);
      expect(result['newStreak'], 2);
      expect(userDataProvider.userData?['dailyStreak'], 2);
    });

    test('handleReward resets streak if a day is missed', () async {
      // Simulate last ad watched 2 days ago
      await fakeFirestore.collection('users').doc(userId).update({
          'lastAdWatchedTimestamp': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
          'dailyStreak': 5, // existing streak
      });
      userDataProvider.listenToUserData();
      await Future.delayed(Duration.zero);

      final result = await userDataProvider.handleReward(50, isGameReward: false);

      expect(result['success'], isTrue);
      expect(userDataProvider.userData?['dailyStreak'], 1, reason: "Streak should reset to 1 after a missed day");
    });


    test('handleReward promotes tier from Bronze to Silver', () async {
      // Set points just below Silver tier threshold
      await fakeFirestore.collection('users').doc(userId).update({'points': 4990});
      userDataProvider.listenToUserData();
      await Future.delayed(Duration.zero);

      final result = await userDataProvider.handleReward(20, isGameReward: false);

      expect(result['success'], isTrue);
      expect(result['tierPromoted'], isTrue);
      expect(result['newTierName'], 'Silver');
      expect(userDataProvider.userData?['tier'], UserTier.silver.index);
      expect(userDataProvider.points, 5010);
    });
    
    test('handleReward promotes tier from Silver to Gold', () async {
      // Set user to Silver tier and points just below Gold threshold
      await fakeFirestore.collection('users').doc(userId).update({
          'points': 9980,
          'tier': UserTier.silver.index,
      });
      userDataProvider.listenToUserData();
      await Future.delayed(Duration.zero);

      final result = await userDataProvider.handleReward(30, isGameReward: false);

      expect(result['success'], isTrue);
      expect(result['tierPromoted'], isTrue);
      expect(result['newTierName'], 'Gold');
      expect(userDataProvider.userData?['tier'], UserTier.gold.index);
      expect(userDataProvider.points, 10010);
    });

    test('handleReward unlocks 'First Points' achievement', () async {
      // Reset points to 0 and remove the achievement if it exists
      await fakeFirestore.collection('users').doc(userId).update({
        'points': 0,
        'unlockedAchievements': [],
      });
      userDataProvider.listenToUserData();
      await Future.delayed(Duration.zero);
      
      final result = await userDataProvider.handleReward(1, isGameReward: false);
      
      final unlocked = (result['unlockedAchievements'] as List<Achievement>).map((a) => a.id).toList();

      expect(result['success'], isTrue);
      expect(unlocked, contains('first_points'));
      expect(userDataProvider.userData?['unlockedAchievements'], contains('first_points'));
    });

  });
}
