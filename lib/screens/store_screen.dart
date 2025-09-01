import 'package:flutter/material.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';
import 'package:go_router/go_router.dart';

class StoreItem {
  final String name;
  final int price;
  final String imageUrl;

  const StoreItem({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  static final List<StoreItem> _items = [
    const StoreItem(
        name: 'Gift Card', price: 100, imageUrl: 'https://picsum.photos/seed/a/200/300'),
    const StoreItem(
        name: 'Movie Ticket', price: 200, imageUrl: 'https://picsum.photos/seed/b/200/300'),
    const StoreItem(
        name: 'T-shirt', price: 500, imageUrl: 'https://picsum.photos/seed/c/200/300'),
    const StoreItem(
        name: 'Coffee Mug', price: 150, imageUrl: 'https://picsum.photos/seed/d/200/300'),
    const StoreItem(
        name: 'Wireless Earbuds',
        price: 2000,
        imageUrl: 'https://picsum.photos/seed/e/200/300'),
    const StoreItem(
        name: 'Smartwatch', price: 5000, imageUrl: 'https://picsum.photos/seed/f/200/300'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RewardlyAppBar(),
      body: CustomScrollView(
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
                  final item = _items[index];
                  return _buildStoreItemCard(context, theme, item);
                },
                childCount: _items.length,
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
      ),
    );
  }

  Widget _buildStoreItemCard(
      BuildContext context, ThemeData theme, StoreItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showRedeemDialog(context, item);
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

  void _showRedeemDialog(BuildContext context, StoreItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.name}" redeemed successfully! (Not really)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
