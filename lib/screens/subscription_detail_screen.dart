import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

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
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  final _notificationDaysController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _paymentPeriod = 'Месяц';
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _currentSubscription = widget.subscription;
    _selectedCategory = _currentSubscription.category == 'Без категории'
        ? null
        : _currentSubscription.category;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = _currentSubscription.name;
    _priceController.text = _currentSubscription.price.toString();
    _noteController.text = _currentSubscription.note;
    _notificationDaysController.text =
        _currentSubscription.notificationDays.toString();
    _selectedDate = _currentSubscription.nextPaymentDate;
    _paymentPeriod = _currentSubscription.paymentPeriod;
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
            const SizedBox(height: 30),
            _buildDeleteButton(),
          ],
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
    );
  }

  Widget _buildPaymentPeriodDropdown() {
    return DropdownButtonFormField<String>(
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

  Widget _buildNotificationDaysField() {
    return TextFormField(
      controller: _notificationDaysController,
      decoration: const InputDecoration(
        labelText: 'Напоминать за дней до оплаты',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

  Widget _buildDeleteButton() {
    return ElevatedButton(
        onPressed: _deleteSubscription,
        child: const Text('Удалить подписку'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
        ));
  }

  void _updateSubscription() async {
    final updatedSubscription = _currentSubscription.copyWith(
      name: _nameController.text,
      price: int.parse(_priceController.text),
      paymentPeriod: _paymentPeriod,
      category: _selectedCategory ?? 'Без категории',
      nextPaymentDate: _selectedDate,
      note: _noteController.text,
      notificationDays: int.parse(_notificationDaysController.text),
    );

    await _notificationService
        .cancelNotification(_currentSubscription.id.hashCode);
    await _scheduleNotification(updatedSubscription);

    HiveService.updateSubscription(widget.index, updatedSubscription);
    Navigator.pop(context, true);
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

  void _deleteSubscription() async {
    await _notificationService
        .cancelNotification(_currentSubscription.id.hashCode);
    HiveService.deleteSubscription(widget.index);
    Navigator.pop(context, true);
  }
}
