import 'package:flutter/material.dart';
import '../models/subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  SubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(subscription.name),
        subtitle: Text('Цена: ${subscription.price} руб. / ${subscription.paymentPeriod}'),
      ),
    );
  }
}