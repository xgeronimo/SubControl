import 'package:flutter/material.dart';
import '../models/subscription_model.dart';

class UncategorizedSubscriptionsSheet extends StatelessWidget {
  final List<Subscription> subscriptions;
  final Function(Subscription) onAddToCategory;

  const UncategorizedSubscriptionsSheet({
    Key? key,
    required this.subscriptions,
    required this.onAddToCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
    );
  }

  Widget _buildContent() {
    return subscriptions.isEmpty
        ? const Center(child: Text('Нет подписок без категории'))
        : ListView.builder(
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              return ListTile(
                title: Text(sub.name),
                subtitle: Text('${sub.price} ₽/${sub.paymentPeriod}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onAddToCategory(sub),
                ),
              );
            },
          );
  }
}
