import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import 'subscriptions_screen.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late List<Category> categories;
  late List<Subscription> subscriptions;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      categories = HiveService.getCategories();
      subscriptions = HiveService.getSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Ждем результат создания категории
              await Navigator.pushNamed(context, '/add-category');
              // Обновляем данные после возврата
              _loadData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final categorySubscriptions = subscriptions
                .where((sub) => sub.category == category.name)
                .toList();
            final totalCost =
                categorySubscriptions.fold(0.0, (sum, sub) => sum + sub.price);

            return _CategoryCard(
              category: category,
              subscriptionsCount: categorySubscriptions.length,
              totalCost: totalCost,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionsScreen(
                      categoryName: category.name,
                      showOnlyCategory: true,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int subscriptionsCount;
  final double totalCost;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.subscriptionsCount,
    required this.totalCost,
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
          padding: const EdgeInsets.all(16.0),
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
                    '$subscriptionsCount ${_getSubscriptionWord(subscriptionsCount)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalCost.toStringAsFixed(2)} ₽/мес',
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
    if (count % 100 >= 11 && count % 100 <= 19) {
      return 'подписок';
    }
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
