import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()!.containsKey('isAdmin') && userDoc.data()!['isAdmin'] == true) {
        setState(() {
          _isAdmin = true;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.request_page), text: 'Withdrawals'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UserList(),
            WithdrawalList(),
          ],
        ),
      ),
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<DocumentSnapshot> _users = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsers({bool loadMore = false, String query = ''}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    Query firestoreQuery = FirebaseFirestore.instance.collection('users').orderBy('email').limit(20);

    if (loadMore && _lastDocument != null) {
      firestoreQuery = firestoreQuery.startAfterDocument(_lastDocument!);
    }

    if (query.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('email', isGreaterThanOrEqualTo: query).where('email', isLessThan: '${query}z');
    }

    try {
      final querySnapshot = await firestoreQuery.get();
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        if (loadMore) {
          _users.addAll(querySnapshot.docs);
        } else {
          _users = querySnapshot.docs;
        }
        _lastDocument = querySnapshot.docs.last;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchUsers(query: _searchController.text);
    });
  }

  Future<void> _toggleAdmin(String uid, bool currentAdminStatus) async {
    // Prevent admin from removing their own status
    if (uid == currentUser?.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot remove your own admin status.')),
      );
      return;
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'isAdmin': !currentAdminStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search by email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                _fetchUsers(loadMore: true, query: _searchController.text);
              }
              return true;
            },
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final userData = user.data() as Map<String, dynamic>;
                final email = userData['email'] ?? 'No email';
                final points = userData['points'] ?? 0;
                final isAdmin = userData.containsKey('isAdmin') && userData['isAdmin'] == true;
                final isCurrentUser = user.id == currentUser?.uid;

                return ListTile(
                  title: Text(email),
                  subtitle: Text('Points: $points'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isAdmin ? 'Admin' : 'User'),
                      const SizedBox(width: 8),
                      Switch(
                        value: isAdmin,
                        // Disable the switch for the current user to prevent self-revocation
                        onChanged: isCurrentUser ? null : (value) => _toggleAdmin(user.id, isAdmin),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (_isLoading) const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class WithdrawalList extends StatefulWidget {
  const WithdrawalList({super.key});

  @override
  State<WithdrawalList> createState() => _WithdrawalListState();
}

class _WithdrawalListState extends State<WithdrawalList> {
  List<DocumentSnapshot> _withdrawals = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchWithdrawals();
  }

  Future<void> _fetchWithdrawals({bool loadMore = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('withdrawals')
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .limit(20);

    if (loadMore && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        if (loadMore) {
          _withdrawals.addAll(querySnapshot.docs);
        } else {
          _withdrawals = querySnapshot.docs;
        }
        _lastDocument = querySnapshot.docs.last;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateWithdrawalStatus(String id, String status) async {
    // Optional: Add confirmation dialog
    await FirebaseFirestore.instance.collection('withdrawals').doc(id).update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _fetchWithdrawals(loadMore: true);
        }
        return true;
      },
      child: ListView.builder(
        itemCount: _withdrawals.length,
        itemBuilder: (context, index) {
          final withdrawal = _withdrawals[index];
          final data = withdrawal.data() as Map<String, dynamic>;
          final amount = data['amount'] ?? 0;
          final userId = data['userId'] ?? 'Unknown';

          return ListTile(
            title: Text('Amount: $amount'),
            subtitle: Text('User ID: $userId'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _updateWithdrawalStatus(withdrawal.id, 'approved'),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _updateWithdrawalStatus(withdrawal.id, 'denied'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
