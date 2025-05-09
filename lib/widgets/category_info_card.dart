import 'package:flutter/material.dart';

class CategoryInfoCard extends StatelessWidget {
  final String categoryName;
  final int subscriptionsCount;
  final double monthlyTotal;
  final double yearlyTotal;

  const CategoryInfoCard({
    Key? key,
    required this.categoryName,
    required this.subscriptionsCount,
    required this.monthlyTotal,
    required this.yearlyTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$subscriptionsCount ${_getSubscriptionWord(subscriptionsCount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildCategoryTag(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountInfo('В месяц', monthlyTotal),
                _buildAmountInfo('В год', yearlyTotal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categoryName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String period, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          period,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} ₽',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getSubscriptionWord(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return 'подписок';
    switch (count % 10) {
      case 1:
        return 'подписка';
      case 2:
      case 3:
      case 4:
        return 'подписки';
      default:
        return 'подписок';
    }
  }
}
