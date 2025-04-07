import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({Key? key}) : super(key: key);

  @override
  _AddSubscriptionScreenState createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _paymentPeriod = 'Месяц';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая подписка'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _addSubscription,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Цена',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Введите цену' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentPeriod,
                decoration: const InputDecoration(
                  labelText: 'Период оплаты',
                  border: OutlineInputBorder(),
                ),
                items: ['Месяц', 'Год'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _paymentPeriod = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
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
                onChanged: (value) => setState(() => _selectedCategory = value),
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
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
