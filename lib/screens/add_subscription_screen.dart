import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final String? preselectedCategory;

  const AddSubscriptionScreen({Key? key, this.preselectedCategory})
      : super(key: key);

  @override
  _AddSubscriptionScreenState createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  final _notificationDaysController = TextEditingController(text: '3');
  String _paymentPeriod = 'Месяц';
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  final List<String> _paymentPeriods = ['Месяц', 'Год'];
  final NotificationService _notificationService = NotificationService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

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
              _buildNameField(),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 16),
              _buildPaymentPeriodDropdown(),
              const SizedBox(height: 16),
              _buildDateSelector(),
              const SizedBox(height: 16),
              _buildNotificationDaysField(),
              const SizedBox(height: 16),
              _buildNoteField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Название',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'Введите название' : null,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Цена (₽)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Введите цену';
        if (int.tryParse(value) == null) return 'Введите целое число';
        return null;
      },
    );
  }

  Widget _buildPaymentPeriodDropdown() {
    return DropdownButtonFormField<String>(
      value: _paymentPeriod,
      decoration: const InputDecoration(
        labelText: 'Период оплаты',
        border: OutlineInputBorder(),
      ),
      items: _paymentPeriods.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) => setState(() => _paymentPeriod = value!),
    );
  }

  Widget _buildDateSelector() {
    return ListTile(
      title: Text(
          "Дата следующей оплаты: ${DateFormat('dd.MM.yyyy').format(_selectedDate)}"),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildNotificationDaysField() {
    return TextFormField(
      controller: _notificationDaysController,
      decoration: const InputDecoration(
        labelText: 'Напоминать за дней до оплаты',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Введите количество дней';
        final days = int.tryParse(value);
        if (days == null || days < 0 || days > 30) {
          return 'Введите число от 0 до 30';
        }
        return null;
      },
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: 'Заметка',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
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
      onChanged: (value) => setState(() => _selectedCategory = value),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
        onPressed: _addSubscription,
        child: const Text('Сохранить подписку'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ));
  }

  void _addSubscription() async {
    if (_formKey.currentState!.validate()) {
      final subscription = Subscription(
        id: const Uuid().v4(),
        name: _nameController.text,
        price: int.parse(_priceController.text),
        paymentPeriod: _paymentPeriod,
        category: _selectedCategory ?? 'Без категории',
        nextPaymentDate: _selectedDate,
        note: _noteController.text,
        notificationDays: int.parse(_notificationDaysController.text),
      );

      await _scheduleNotification(subscription);
      HiveService.addSubscription(subscription);
      Navigator.pop(context);
    }
  }

  Future<void> _scheduleNotification(Subscription subscription) async {
    if (subscription.notificationDays > 0) {
      final notificationDate = subscription.nextPaymentDate.subtract(
        Duration(days: subscription.notificationDays),
      );

      if (notificationDate.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: subscription.id.hashCode,
          title: 'Напоминание о подписке',
          body:
              'Через ${subscription.notificationDays} дней оплата: ${subscription.name}',
          date: notificationDate,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _notificationDaysController.dispose();
    super.dispose();
  }
}
