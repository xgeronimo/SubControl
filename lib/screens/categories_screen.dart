import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../widgets/category_card.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _createNewCategory(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsetsDirectional.only(bottom: 16),
                title: Text(
                  "Категории",
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                    fontSize: 22,
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            categories.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final category = categories[index];
                          final categorySubs = subscriptions
                              .where((sub) => sub.category == category.name)
                              .toList();

                          final total = categorySubs.fold<int>(0, (sum, sub) {
                            final monthlyPrice = sub.paymentPeriod == 'Год'
                                ? sub.price ~/ 12
                                : sub.price;
                            return sum + monthlyPrice;
                          });

                          return CategoryCard(
                            category: category,
                            count: categorySubs.length,
                            total: total,
                            onTap: () => _openCategory(context, category),
                          );
                        },
                        childCount: categories.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
