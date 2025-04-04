import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../widgets/subscription_card.dart';
import 'add_item_screen.dart';
import 'subscription_detail_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  final String? categoryName;
  final bool showOnlyCategory;

  const SubscriptionsScreen({
    Key? key,
    this.categoryName,
    this.showOnlyCategory = false,
  }) : super(key: key);

  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late List<Subscription> subscriptions;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    if (widget.showOnlyCategory && widget.categoryName != null) {
      subscriptions = HiveService.getSubscriptionsByCategory(widget.categoryName!);
    } else {
      subscriptions = HiveService.getSubscriptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.showOnlyCategory
            ? Text('Подписки: ${widget.categoryName}')
            : const Text('Все подписки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Добавляем подписку и ждем результата
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemScreen()),
              );
              // Обновляем список после возврата
              setState(() {
                _loadSubscriptions();
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadSubscriptions();
          });
        },
        child: subscriptions.isEmpty
            ? const Center(
          child: Text(
            'Нет подписок',
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final subscription = subscriptions[index];
            return SubscriptionCard(
              subscription: subscription,
              onTap: () => _navigateToDetail(context, subscription, index),
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Subscription subscription, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionDetailScreen(
          subscription: subscription,
          index: index,
        ),
      ),
    ).then((_) => setState(() => _loadSubscriptions()));
  }
}