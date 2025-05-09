import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int count;
  final int total;
  final VoidCallback onTap;

  const CategoryCard({
    required this.category,
    required this.count,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count ${_getSubscriptionWord(count)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${total.toString()} ₽/мес',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
