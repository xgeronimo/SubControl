import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sub_control/services/notification_service.dart';
import 'package:sub_control/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late Future<bool> _notificationsEnabled;
  late bool _isDarkMode;
  //late Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = NotificationService().notificationsEnabled;
    _isDarkMode = Provider.of<AppTheme>(context, listen: false).isDarkMode;
    //_packageInfo = PackageInfo.fromPlatform();
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppTheme>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FutureBuilder<bool>(
                  future: _notificationsEnabled,
                  builder: (context, snapshot) {
                    final isEnabled = snapshot.data ?? true;
                    return SwitchListTile(
                      title: const Text('Уведомления'),
                      subtitle:
                          const Text('Включить/выключить все уведомления'),
                      value: isEnabled,
                      onChanged: (value) async {
                        await NotificationService()
                            .setNotificationsEnabled(value);
                        setState(() {
                          _notificationsEnabled = Future.value(value);
                        });
                      },
                    );
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Тёмная тема'),
                  value: _isDarkMode,
                  onChanged: (value) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isDark', value);
                    appTheme.toggleTheme(value);
                    setState(() => _isDarkMode = value);
                  },
                ),
                const Divider(),
                _buildLinkTile(
                  icon: Icons.support_agent,
                  title: 'Написать в тех. поддержку',
                  onTap: () => _launchURL(''),
                ),
                _buildLinkTile(
                  icon: Icons.star_rate_rounded,
                  title: 'Оценить приложение',
                  onTap: () => _launchURL(''),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Версия 1.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: onTap,
    );
  }
}
