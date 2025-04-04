import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/hive_service.dart';
import 'subscriptions_screen.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = HiveService.getCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text('Категории'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.name),
            onTap: () {
              // Прямой переход к подпискам этой категории
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionsScreen(
                    categoryName: category.name, // Передаем имя категории
                    showOnlyCategory: true, // Флаг для фильтрации
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}