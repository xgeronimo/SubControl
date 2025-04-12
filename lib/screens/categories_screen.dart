import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../widgets/category_card.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
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
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Все категории',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categories.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categorySubs = subscriptions
                      .where((sub) => sub.category == category.name)
                      .toList();
                  final total = categorySubs.fold(
                      0, (sum, sub) => sum + sub.price.toInt());

                  return CategoryCard(
                    category: category,
                    count: categorySubs.length,
                    total: total,
                    onTap: () => _openCategory(context, category),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewCategory(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Нет созданных категорий',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите + чтобы создать новую',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _openCategory(BuildContext context, Category category) {
    final index = categories.indexOf(category);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(
          category: category,
          categoryIndex: index,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _createNewCategory(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/add-category');
    if (result == true) {
      _loadData();
    }
  }
}