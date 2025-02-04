import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  @override
  _AddSubscriptionScreenState createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _paymentPeriod = 'Месяц';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить подписку'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Название'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Цена'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите цену';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _paymentPeriod,
                onChanged: (value) {
                  setState(() {
                    _paymentPeriod = value!;
                  });
                },
                items: ['Месяц', 'Год'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final subscription = Subscription(
                      name: _nameController.text,
                      price: double.parse(_priceController.text),
                      paymentPeriod: _paymentPeriod,
                    );
                    HiveService.addSubscription(subscription);

                    // Возвращаемся на экран "Подписки"
                    Navigator.pop(context, true); // Возвращаемся на экран "Подписки"
                  }
                },
                child: Text('Добавить подписку'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}