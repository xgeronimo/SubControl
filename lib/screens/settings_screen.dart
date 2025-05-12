import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<bool> _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = NotificationService().notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          FutureBuilder<bool>(
            future: _notificationsEnabled,
            builder: (context, snapshot) {
              final isEnabled = snapshot.data ?? true;
              return SwitchListTile(
                title: Text('Уведомления'),
                subtitle: Text('Включить/выключить все уведомления'),
                value: isEnabled,
                onChanged: (value) async {
                  await NotificationService().setNotificationsEnabled(value);
                  setState(() {
                    _notificationsEnabled = Future.value(value);
                  });
                },
              );
            },
          ),
          // ... другие настройки
        ],
      ),
    );
  }
}
