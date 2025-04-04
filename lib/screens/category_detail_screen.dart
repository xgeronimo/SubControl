import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_screen.dart';

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
  late List<Subscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    _subscriptions = HiveService.getSubscriptionsByCategory(widget.category.name);
  }

  void _refreshSubscriptions() {
    setState(() {
      _loadSubscriptions();
    });
  }

  void _navigateToSubscriptionDetail(Subscription subscription, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionDetailScreen(
          subscription: subscription,
          index: index,
        ),
      ),
    ).then((_) => _refreshSubscriptions());
  }

  void _deleteCategory() {
    HiveService.deleteCategory(widget.categoryIndex);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteCategory,
            tooltip: 'Удалить категорию',
          ),
        ],
      ),
      body: _subscriptions.isEmpty
          ? Center(
        child: Text(
          'Нет подписок в этой категории',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: _subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = _subscriptions[index];
          return SubscriptionCard(
            subscription: subscription,
            onTap: () => _navigateToSubscriptionDetail(subscription, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Можно добавить переход на экран добавления подписки
          // с предустановленной текущей категорией
        },
        tooltip: 'Добавить подписку',
      ),
    );
  }
}