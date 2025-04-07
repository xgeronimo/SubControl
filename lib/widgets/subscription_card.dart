import 'package:flutter/material.dart';
import '../models/subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({
    required this.subscription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(subscription.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Цена: ${subscription.price} руб./${subscription.paymentPeriod}'),
            Text('Категория: ${subscription.category}'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
