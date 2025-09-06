import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/providers/user_data_provider.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, bool> _checkIns = {};
  bool _isLoadingCheckIns = true;
  bool _isCheckingIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCheckInsForYear(_focusedDay.year);
    });
  }

  Future<void> _fetchCheckInsForYear(int year) async {
    final user = context.read<UserDataProvider>().user;
    if (user == null || !mounted) return;

    setState(() {
      _isLoadingCheckIns = true;
    });

    try {
      final checkIns = await _getCheckInsForYear(user.uid, year);
      if (mounted) {
        setState(() {
          _checkIns.addAll(checkIns);
          _isLoadingCheckIns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCheckIns = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load your check-in history. Please try again later.')),
        );
      }
    }
  }

  Future<Map<DateTime, bool>> _getCheckInsForYear(String userId, int year) async {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('daily_check_ins')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfYear)
        .where('timestamp', isLessThanOrEqualTo: endOfYear)
        .get();

    final checkIns = <DateTime, bool>{};
    for (final doc in snapshot.docs) {
      final timestamp = doc['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      checkIns[DateTime.utc(date.year, date.month, date.day)] = true;
    }
    return checkIns;
  }

  Future<void> _checkIn(UserModel user) async {
    if (!mounted) return;

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final now = DateTime.now();
      final today = DateTime.utc(now.year, now.month, now.day);

      final result = await FirebaseFirestore.instance.runTransaction<Map<String, int>>((transaction) async {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception("User document not found!");
        }

        final userData = userSnapshot.data()!;
        final lastCheckIn = (userData['lastCheckIn'] as Timestamp?)?.toDate();

        if (lastCheckIn != null && isSameDay(lastCheckIn, now)) {
          return {'alreadyCheckedIn': 1};
        }

        int newStreak = 1;
        if (lastCheckIn != null) {
          final yesterday = today.subtract(const Duration(days: 1));
           final lastCheckInDate = DateTime.utc(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day);
          if (isSameDay(lastCheckInDate, yesterday)) {
            newStreak = (userData['streak'] ?? 0) + 1;
          }
        }

        int pointsEarned = 10;
        int bonusPoints = 0;
        if (newStreak % 30 == 0) {
          bonusPoints = 250;
        } else if (newStreak % 14 == 0) {
          bonusPoints = 100;
        } else if (newStreak % 7 == 0) {
          bonusPoints = 50;
        } else if (newStreak % 3 == 0) {
          bonusPoints = 20;
        }

        pointsEarned += bonusPoints;

        transaction.update(userRef, {
          'lastCheckIn': Timestamp.now(),
          'streak': newStreak,
          'points': FieldValue.increment(pointsEarned),
        });

        final checkInRef = FirebaseFirestore.instance.collection('daily_check_ins').doc();
        transaction.set(checkInRef, {
          'userId': user.uid,
          'timestamp': Timestamp.now(),
        });

        return {'pointsEarned': pointsEarned, 'newStreak': newStreak, 'bonusPoints': bonusPoints};
      });

      if (mounted) {
        if (result.containsKey('alreadyCheckedIn')) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have already checked in today.')),
            );
        } else {
          final pointsEarned = result['pointsEarned']!;
          final newStreak = result['newStreak']!;
          final bonusPoints = result['bonusPoints']!;
          _showCheckInConfirmation(pointsEarned, newStreak, bonusPoints);
          setState(() {
            _checkIns[today] = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
      }
    }
  }

  void _showCheckInConfirmation(int points, int streak, int bonus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Checked In!', style: Theme.of(context).textTheme.headlineMedium)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(),
              const SizedBox(height: 16),
              Text('You earned $points points!', style: Theme.of(context).textTheme.titleLarge)
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(),
              if (bonus > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('+$bonus bonus points for your streak!', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green.shade600))
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(),
                ),
              const SizedBox(height: 16),
              Text('Your new streak is $streak days!', style: Theme.of(context).textTheme.titleMedium)
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .slideY(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          final user = userDataProvider.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final today = DateTime.utc(now.year, now.month, now.day);
          final isCheckedInToday = _checkIns[today] ?? false;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2022, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        if (_focusedDay.year != focusedDay.year) {
                           _fetchCheckInsForYear(focusedDay.year);
                        }
                        _focusedDay = focusedDay;
                      },
                      eventLoader: (day) {
                        if (_checkIns[DateTime.utc(day.year, day.month, day.day)] ?? false) {
                          return ['checked_in'];
                        }
                        return [];
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              right: 1,
                              bottom: 1,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green.shade600,
                                size: 18,
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  if (_isLoadingCheckIns)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isCheckedInToday || _isCheckingIn ? null : () => _checkIn(user),
                     style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 16),
                    ),
                    child: _isCheckingIn ? const CircularProgressIndicator(color: Colors.white) : const Text('Check-in for Today'),
                  ).animate().fadeIn(delay: 200.ms).slideY(),
                  const SizedBox(height: 24),
                  Text('Current Streak: ${user.streak} days',
                          style: Theme.of(context).textTheme.titleLarge)
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
