import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final Subscription subscription;
  final int index;

  SubscriptionDetailScreen({required this.subscription, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subscription.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Название: ${subscription.name}',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text(
                'Цена: ${subscription.price} руб. / ${subscription.paymentPeriod}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Удаление подписки
                HiveService.deleteSubscription(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Подписка "${subscription.name}" удалена')),
                );
                Navigator.pop(context); // Возврат на предыдущий экран
              },
              child: Text('Удалить подписку'),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red), // Измените primary на backgroundColor
            ),
          ],
        ),
      ),
    );
  }
}
