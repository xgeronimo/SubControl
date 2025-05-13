import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sub_control/screens/subscription_detail_screen.dart';
import '../models/category_model.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../widgets/subscription_card.dart';
import '../widgets/category_info_card.dart';
import '../widgets/uncategorized_subscriptions_sheet.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  final int categoryIndex;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.categoryIndex,
  });

  @override
  CategoryDetailScreenState createState() => CategoryDetailScreenState();
}

class CategoryDetailScreenState extends State<CategoryDetailScreen>
    with TickerProviderStateMixin {
  late List<Subscription> _categorySubscriptions;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSubscriptions() {
    setState(() {
      _categorySubscriptions = HiveService.getSubscriptions()
          .where((sub) => sub.category == widget.category.name)
          .toList()
        ..sort((a, b) => b.price.compareTo(a.price));
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthlyTotal = _calculateMonthlyTotal();
    final yearlyTotal = monthlyTotal * 12;

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(monthlyTotal, yearlyTotal),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildBody(double monthlyTotal, double yearlyTotal) {
    return Column(
      children: [
        CategoryInfoCard(
          categoryName: widget.category.name,
          subscriptionsCount: _categorySubscriptions.length,
          monthlyTotal: monthlyTotal,
          yearlyTotal: yearlyTotal,
        ),
        Expanded(
          child: _categorySubscriptions.isEmpty
              ? _buildEmptyState()
              : _buildSubscriptionList(),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _categorySubscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _categorySubscriptions[index];
        return _buildDismissibleSubscription(subscription, index);
      },
    );
  }

  Widget _buildDismissibleSubscription(Subscription subscription, int index) {
    return Dismissible(
      key: Key('${subscription.name}_${DateTime.now().millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      secondaryBackground: _buildDismissSecondaryBackground(),
      confirmDismiss: (direction) => _confirmDismiss(subscription),
      onDismissed: (direction) => _handleDismissed(subscription, index),
      movementDuration: const Duration(milliseconds: 200),
      dismissThresholds: const {DismissDirection.endToStart: 0.4},
      child: SubscriptionCard(
        subscription: subscription,
        onTap: () => _navigateToDetail(subscription, index),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildDismissSecondaryBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 30),
    );
  }

  Future<bool?> _confirmDismiss(Subscription subscription) async {
    await HapticFeedback.lightImpact();
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить из категории?'),
        content: Text(
            'Подписка "${subscription.name}" будет перемещена в "Без категории"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleDismissed(Subscription subscription, int index) {
    _removeSubscriptionFromCategory(subscription, index);
  }

  void _removeSubscriptionFromCategory(Subscription subscription, int index) {
    final box = HiveService.getSubscriptionBox();
    final globalIndex = box.keyAt(box.values.toList().indexOf(subscription));

    HiveService.updateSubscription(
      globalIndex,
      subscription.copyWith(category: 'Без категории'),
    );

    setState(() => _categorySubscriptions.removeAt(index));

    _showUndoSnackbar(subscription, globalIndex);
  }

  void _showUndoSnackbar(Subscription subscription, int globalIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Подписка перемещена в "Без категории"'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () => _undoDelete(subscription, globalIndex),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _undoDelete(Subscription subscription, int globalIndex) {
    HiveService.updateSubscription(
      globalIndex,
      subscription.copyWith(category: widget.category.name),
    );
    setState(() {
      _categorySubscriptions.add(subscription);
      _categorySubscriptions.sort((a, b) => b.price.compareTo(a.price));
    });
  }

  double _calculateMonthlyTotal() {
    return _categorySubscriptions.fold<double>(0, (sum, sub) {
      final price = sub.price.toDouble();
      return sum + (sub.paymentPeriod == 'Год' ? price / 12 : price);
    });
  }

  void _navigateToDetail(Subscription subscription, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionDetailScreen(
          subscription: subscription,
          index: index,
        ),
      ),
    );
    _loadSubscriptions();
  }

  void _showUncategorizedSubscriptions() {
    final uncategorizedSubs = HiveService.getSubscriptions()
        .where((sub) => sub.category == 'Без категории')
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UncategorizedSubscriptionsSheet(
        subscriptions: uncategorizedSubs,
        onAddToCategory: _moveSubscriptionToCategory,
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
        SnackBar(
          content: Text('Подписка добавлена в ${widget.category.name}'),
          duration: const Duration(seconds: 2),
        ),
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
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) _deleteCategory();
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
