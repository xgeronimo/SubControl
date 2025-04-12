import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  final int categoryIndex;

  const CategoryDetailScreen({
    Key? key,
    required this.category,
    required this.categoryIndex,
  }) : super(key: key);

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late List<Subscription> _categorySubscriptions;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    setState(() {
      _categorySubscriptions = HiveService.getSubscriptions()
          .where((sub) => sub.category == widget.category.name)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showUncategorizedSubscriptions,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Удалить категорию',
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildStatsCard(),
        Expanded(
          child: _categorySubscriptions.isEmpty
              ? _buildEmptyState()
              : _buildSubscriptionList(),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final total = _categorySubscriptions.fold(
        0, (sum, sub) => sum + sub.price);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${_categorySubscriptions.length} подписок'),
            const SizedBox(height: 8),
            Text(
              '$total ₽/мес',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Нет подписок в этой категории'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showUncategorizedSubscriptions,
            child: const Text('Добавить подписку'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionList() {
    return ListView.builder(
      itemCount: _categorySubscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _categorySubscriptions[index];
        return ListTile(
          title: Text(subscription.name),
          subtitle: Text('${subscription.price} ₽/${subscription.paymentPeriod}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeSubscriptionFromCategory(subscription),
          ),
        );
      },
    );
  }

  void _showUncategorizedSubscriptions() {
    final uncategorizedSubs = HiveService.getSubscriptions()
        .where((sub) => sub.category == 'Без категории')
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Подписки без категории',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: uncategorizedSubs.isEmpty
                  ? const Center(child: Text('Нет подписок без категории'))
                  : ListView.builder(
                itemCount: uncategorizedSubs.length,
                itemBuilder: (context, index) {
                  final sub = uncategorizedSubs[index];
                  return ListTile(
                    title: Text(sub.name),
                    subtitle: Text('${sub.price} ₽/${sub.paymentPeriod}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _moveSubscriptionToCategory(sub),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _moveSubscriptionToCategory(Subscription subscription) {
    final index = HiveService.getSubscriptions().indexOf(subscription);
    if (index != -1) {
      HiveService.updateSubscription(
        index,
        subscription.copyWith(category: widget.category.name),
      );
      Navigator.pop(context);
      setState(() => _loadSubscriptions());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Подписка добавлена в ${widget.category.name}')),
      );
    }
  }

  void _removeSubscriptionFromCategory(Subscription subscription) {
    final index = HiveService.getSubscriptions().indexOf(subscription);
    if (index != -1) {
      HiveService.updateSubscription(
        index,
        subscription.copyWith(category: 'Без категории'),
      );
      setState(() => _loadSubscriptions());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Подписка удалена из категории')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text(
          _categorySubscriptions.isEmpty
              ? 'Категория "${widget.category.name}" будет удалена'
              : 'Категория "${widget.category.name}" и ${_categorySubscriptions.length} подписок будут перемещены в "Без категории"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteCategory();
    }
  }

  void _deleteCategory() {
    final subscriptions = HiveService.getSubscriptions();
    for (var i = 0; i < subscriptions.length; i++) {
      if (subscriptions[i].category == widget.category.name) {
        HiveService.updateSubscription(
          i,
          subscriptions[i].copyWith(category: 'Без категории'),
        );
      }
    }

    HiveService.deleteCategory(widget.categoryIndex);
    Navigator.pop(context);
  }
}