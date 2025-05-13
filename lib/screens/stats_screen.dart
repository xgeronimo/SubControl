import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';

class StatsScreen extends StatelessWidget {
  final List<Subscription> subscriptions;
  final double totalMonthly;

  const StatsScreen({
    super.key,
    required this.subscriptions,
    required this.totalMonthly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Статистика расходов',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatCard(context, 'Всего подписок', '${subscriptions.length}'),
          const SizedBox(height: 15),
          _buildStatCard(
              context, 'В месяц', '${totalMonthly.toStringAsFixed(2)} ₽'),
          const SizedBox(height: 15),
          _buildStatCard(
              context, 'В год', '${(totalMonthly * 12).toStringAsFixed(2)} ₽'),
          const SizedBox(height: 25),
          const Text(
            'Расходы по категориям:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildCategoryStats(context, subscriptions, totalMonthly),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStats(BuildContext context,
      List<Subscription> subscriptions, double totalMonthly) {
    final categories = HiveService.getCategories();
    final categoryStats = <String, double>{};

    for (var category in categories) {
      final categorySubs =
          subscriptions.where((s) => s.category == category.name);
      final total = categorySubs.fold<double>(0, (sum, sub) {
        final price = sub.price.toDouble();
        return sum + (sub.paymentPeriod == 'Год' ? price / 12 : price);
      });
      if (total > 0) categoryStats[category.name] = total;
    }

    final uncategorized =
        subscriptions.where((s) => s.category == 'Без категории');
    final uncategorizedTotal = uncategorized.fold<double>(0, (sum, sub) {
      final price = sub.price.toDouble();
      return sum + (sub.paymentPeriod == 'Год' ? price / 12 : price);
    });
    if (uncategorizedTotal > 0) {
      categoryStats['Без категории'] = uncategorizedTotal;
    }

    if (categoryStats.isEmpty) {
      return const Center(child: Text('Нет данных по категориям'));
    }

    return ListView.builder(
      itemCount: categoryStats.length,
      itemBuilder: (context, index) {
        final categoryName = categoryStats.keys.elementAt(index);
        final amount = categoryStats.values.elementAt(index);
        final percentage =
            totalMonthly > 0 ? (amount / totalMonthly * 100).round() : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      categoryName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: totalMonthly > 0 ? amount / totalMonthly : 0,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.primaries[index % Colors.primaries.length],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${amount.toStringAsFixed(2)} ₽',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$percentage% от общих расходов',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
