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
  Map<DateTime, bool> _checkIns = {};
  bool _isLoadingCheckIns = true;

  @override
  void initState() {
    super.initState();
    _fetchCheckInsForCurrentMonth();
  }

  Future<void> _fetchCheckInsForCurrentMonth() async {
    final user = context.read<UserDataProvider>().user;
    if (user == null) return;

    setState(() {
      _isLoadingCheckIns = true;
    });

    final checkIns = await _getCheckInsForMonth(user.uid, _focusedDay);

    if (mounted) {
      setState(() {
        _checkIns = checkIns;
        _isLoadingCheckIns = false;
      });
    }
  }

  Future<Map<DateTime, bool>> _getCheckInsForMonth(
      String userId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('daily_check_ins')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .where('timestamp', isLessThanOrEqualTo: endOfMonth)
        .get();

    final checkIns = <DateTime, bool>{};
    for (final doc in snapshot.docs) {
      final timestamp = doc['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      checkIns[DateTime(date.year, date.month, date.day)] = true;
    }
    return checkIns;
  }

  Future<void> _checkIn(UserModel user) async {
    if (!mounted) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = 1;
    if (user.lastCheckIn != null) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (isSameDay(user.lastCheckIn, yesterday)) {
        newStreak = user.streak + 1;
      } 
    }

    int pointsEarned = 10;
    if (newStreak % 30 == 0) {
      pointsEarned += 250;
    } else if (newStreak % 14 == 0) {
      pointsEarned += 100;
    } else if (newStreak % 7 == 0)  {
      pointsEarned += 50;
    } else if (newStreak % 3 == 0)  {
      pointsEarned += 20;
    }

    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    batch.set(
      userRef,
      {
        'lastCheckIn': Timestamp.now(),
        'streak': newStreak,
        'points': FieldValue.increment(pointsEarned),
      },
      SetOptions(merge: true),
    );

    final checkInRef = FirebaseFirestore.instance.collection('daily_check_ins').doc();
    batch.set(checkInRef, {
      'userId': user.uid,
      'timestamp': Timestamp.now(),
    });

    await batch.commit();

    if (mounted) {
      // No need to set state here, the UserDataProvider will notify listeners
      _showCheckInConfirmation(pointsEarned, newStreak);
      setState(() {
        _checkIns[today] = true;
      });
    }
  }

  void _showCheckInConfirmation(int points, int streak) {
    showModalBottomSheet(
      context: context,
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
          final today = DateTime(now.year, now.month, now.day);
          final isCheckedInToday = user.lastCheckIn != null && isSameDay(user.lastCheckIn, today);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TableCalendar(
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
                      _focusedDay = focusedDay;
                      _fetchCheckInsForCurrentMonth();
                    },
                    eventLoader: (day) {
                      if (_checkIns[DateTime(day.year, day.month, day.day)] == true) {
                        return ['checked_in'];
                      }
                      return [];
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return const Positioned(
                            right: 1,
                            bottom: 1,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  if (_isLoadingCheckIns)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isCheckedInToday ? null : () => _checkIn(user),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 16),
                    ),
                    child: const Text('Check-in for Today'),
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
