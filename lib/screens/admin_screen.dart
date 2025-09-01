import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
  List<DocumentSnapshot> _users = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  Future<void> _fetchUsers({bool loadMore = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance.collection('users').orderBy('email').limit(20);
    if (loadMore && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    if (_searchController.text.isNotEmpty) {
      query = query.where('email', isGreaterThanOrEqualTo: _searchController.text).where('email', isLessThan: '${_searchController.text}z');
    }

    final querySnapshot = await query.get();
    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    if (loadMore) {
      _users.addAll(querySnapshot.docs);
    } else {
      _users = querySnapshot.docs;
    }

    _lastDocument = querySnapshot.docs.last;
    setState(() {
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (_users.isNotEmpty) {
      setState(() {
        _users = [];
        _lastDocument = null;
        _hasMore = true;
      });
    }
    _fetchUsers();
  }

  Future<void> _toggleAdmin(String uid, bool currentAdminStatus) async {
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
          child: ListView.builder(
            itemCount: _users.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _users.length) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TextButton(onPressed: () => _fetchUsers(loadMore: true), child: const Text('Load More'));
              }

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
                      onChanged: isCurrentUser ? null : (value) => _toggleAdmin(user.id, isAdmin),
                    ),
                  ],
                ),
              );
            },
          ),
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

    final querySnapshot = await query.get();
    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    if (loadMore) {
      _withdrawals.addAll(querySnapshot.docs);
    } else {
      _withdrawals = querySnapshot.docs;
    }

    _lastDocument = querySnapshot.docs.last;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _withdrawals.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _withdrawals.length) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TextButton(onPressed: () => _fetchWithdrawals(loadMore: true), child: const Text('Load More'));
        }

        final withdrawal = _withdrawals[index];
        final amount = withdrawal['amount'];
        final userId = withdrawal['userId'];

        return ListTile(
          title: Text('Amount: $amount'),
          subtitle: Text('User ID: $userId'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  FirebaseFirestore.instance.collection('withdrawals').doc(withdrawal.id).update({'status': 'approved'});
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  FirebaseFirestore.instance.collection('withdrawals').doc(withdrawal.id).update({'status': 'denied'});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
