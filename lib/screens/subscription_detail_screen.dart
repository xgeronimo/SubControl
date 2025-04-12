import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final Subscription subscription;
  final int index;

  const SubscriptionDetailScreen({
    Key? key,
    required this.subscription,
    required this.index,
  }) : super(key: key);

  @override
  _SubscriptionDetailScreenState createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  late Subscription _currentSubscription;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _currentSubscription = widget.subscription;
    _selectedCategory = _currentSubscription.category == 'Без категории'
        ? null
        : _currentSubscription.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentSubscription.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateSubscription,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Название: ${_currentSubscription.name}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(
                'Цена: ${_currentSubscription.price} ₽/${_currentSubscription.paymentPeriod}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildCategoryDropdown(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _deleteSubscription,
              child: const Text('Удалить подписку'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Категория',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Без категории'),
        ),
        ...HiveService.getCategories()
            .map((cat) => cat.name)
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  void _updateSubscription() {
    final updatedSubscription = Subscription(
      name: _currentSubscription.name,
      price: _currentSubscription.price,
      paymentPeriod: _currentSubscription.paymentPeriod,
      category: _selectedCategory ?? 'Без категории',
    );

    HiveService.updateSubscription(widget.index, updatedSubscription);
    Navigator.pop(context, true);
  }

  void _deleteSubscription() {
    HiveService.deleteSubscription(widget.index);
    Navigator.pop(context, true);
  }
}
