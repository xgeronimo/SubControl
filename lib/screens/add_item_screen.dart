import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import 'subscriptions_screen.dart';

class AddItemScreen extends StatefulWidget {
  final String? preselectedCategory;

  const AddItemScreen({Key? key, this.preselectedCategory}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _paymentPeriod = 'Месяц';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая подписка'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (value) => value!.isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Цена'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Введите цену' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentPeriod,
                items: ['Месяц', 'Год'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _paymentPeriod = value!),
                decoration: const InputDecoration(labelText: 'Период оплаты'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
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
                onChanged: (value) => setState(() => _selectedCategory = value),
                decoration: const InputDecoration(labelText: 'Категория'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addSubscription,
                child: const Text('Сохранить подписку'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSubscription() {
    if (_formKey.currentState!.validate()) {
      final subscription = Subscription(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        paymentPeriod: _paymentPeriod,
        category: _selectedCategory ?? 'Без категории',
      );

      HiveService.addSubscription(subscription);

      // Возвращаемся на предыдущий экран (который должен быть SubscriptionsScreen)
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}