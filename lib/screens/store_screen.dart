import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/models/user_tier.dart';
import 'package:rewardly/providers/user_data_provider.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreItem {
  final String name;
  final int price;
  final String imageUrl;
  final UserTier requiredTier;

  const StoreItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.requiredTier = UserTier.bronze,
  });
}

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {

  static final List<StoreItem> _items = [
    const StoreItem(
        name: 'Gift Card', price: 100, imageUrl: 'https://picsum.photos/seed/a/200/300'),
    const StoreItem(
        name: 'Movie Ticket', price: 200, imageUrl: 'https://picsum.photos/seed/b/200/300'),
    const StoreItem(
        name: 'T-shirt', price: 500, imageUrl: 'https://picsum.photos/seed/c/200/300', requiredTier: UserTier.silver),
    const StoreItem(
        name: 'Coffee Mug', price: 150, imageUrl: 'https://picsum.photos/seed/d/200/300'),
    const StoreItem(
        name: 'Wireless Earbuds',
        price: 2000,
        imageUrl: 'https://picsum.photos/seed/e/200/300', requiredTier: UserTier.silver),
    const StoreItem(
        name: 'Smartwatch', price: 5000, imageUrl: 'https://picsum.photos/seed/f/200/300', requiredTier: UserTier.gold),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const RewardlyAppBar(),
      body: user == null
          ? _buildLoggedOutView(context, theme)
          : _buildStoreView(context, theme),
    );
  }

  Widget _buildLoggedOutView(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store_outlined, size: 80),
          const SizedBox(height: 20),
          Text('You are not logged in', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            'Log in to see the amazing rewards you can get!',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreView(BuildContext context, ThemeData theme) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        final userTier = UserTier.values[userDataProvider.userData?['tier'] ?? 0];
        final userPoints = userDataProvider.points;

        final filteredItems = _items.where((item) => userTier.index >= item.requiredTier.index).toList();

        return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Redeem your points for amazing rewards!',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredItems[index];
                  return _buildStoreItemCard(context, theme, item, userPoints);
                },
                childCount: filteredItems.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Home'),
              ),
            ),
          ),
        ],
      );
      },
    );
  }

  Widget _buildStoreItemCard(
      BuildContext context, ThemeData theme, StoreItem item, int userPoints) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showRedeemDialog(context, item, userPoints);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'store_item_${item.name}',
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.error));
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      '${item.price} Points',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: theme.primaryColor.withAlpha(25),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, StoreItem item, int userPoints) {
    if (userPoints >= item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.name}" redeemed successfully! (Not really)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have enough points to redeem this item.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
