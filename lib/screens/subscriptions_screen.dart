import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Subscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    subscriptions = HiveService.getSubscriptions();
  }

  void _refreshList() {
    setState(() {
      subscriptions = HiveService.getSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Подписки'),
      ),
      body: ListView.builder(
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = subscriptions[index];
          return GestureDetector(
            onTap: () {
              // Переход на экран с деталями подписки
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionDetailScreen(
                    subscription: subscription,
                    index: index,
                  ),
                ),
              ).then((_) {
                // Обновление списка после возврата
                _refreshList();
              });
            },
            child: SubscriptionCard(subscription: subscription),
          );
        },
      ),
    );
  }
}
