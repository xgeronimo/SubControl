import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Основные настройки',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Тема приложения'),
            subtitle: Text('Светлая / Темная'),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Уведомления'),
            subtitle: Text('Настройка уведомлений'),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Резервное копирование'),
            subtitle: Text('Экспорт/импорт данных'),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}
