import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to redeem points.'))
          : Column(
              children: [
                _buildUserPoints(user.uid),
                Expanded(child: _buildRewardsGrid(context, user.uid)),
              ],
            ),
    );
  }

  Widget _buildUserPoints(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Your Points: ...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          );
        }
        final userPoints = (snapshot.data!.data() as Map<String, dynamic>)['points'] ?? 0;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Your Points: $userPoints', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildRewardsGrid(BuildContext context, String uid) {
    final List<Map<String, dynamic>> rewards = [
      {'name': 'Gift Card \$5', 'points': 500, 'image': 'https://via.placeholder.com/150'},
      {'name': 'Gift Card \$10', 'points': 1000, 'image': 'https://via.placeholder.com/150'},
      {'name': 'Gift Card \$25', 'points': 2500, 'image': 'https://via.placeholder.com/150'},
      {'name': 'Headphones', 'points': 5000, 'image': 'https://via.placeholder.com/150'},
      {'name': 'Smartwatch', 'points': 10000, 'image': 'https://via.placeholder.com/150'},
      {'name': 'Bluetooth Speaker', 'points': 7500, 'image': 'https://via.placeholder.com/150'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(reward['image'], fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reward['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${reward['points']} points', style: TextStyle(color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () => _showRedeemConfirmation(context, uid, reward),
                  child: const Text('Redeem'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRedeemConfirmation(BuildContext context, String uid, Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Redemption'),
          content: Text('Are you sure you want to redeem ${reward['name']} for ${reward['points']} points?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Redeem'),
              onPressed: () {
                _redeemPoints(context, uid, reward);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _redeemPoints(BuildContext context, String uid, Map<String, dynamic> reward) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final redeemHistoryRef = FirebaseFirestore.instance.collection('redeem_history');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final userPoints = (snapshot.data() as Map<String, dynamic>)['points'] ?? 0;

      if (userPoints >= reward['points']) {
        final newPoints = userPoints - reward['points'];
        transaction.update(userRef, {'points': newPoints});
        transaction.set(redeemHistoryRef.doc(), {
          'userId': uid,
          'rewardName': reward['name'],
          'points': reward['points'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        Fluttertoast.showToast(
            msg: 'Reward redeemed successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: 'You don\'t have enough points.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }
}
