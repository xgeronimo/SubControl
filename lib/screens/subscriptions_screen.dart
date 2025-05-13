import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  final String? categoryName;
  final bool showOnlyCategory;

  const SubscriptionsScreen({
    super.key,
    this.categoryName,
    this.showOnlyCategory = false,
  });

  @override
  SubscriptionsScreenState createState() => SubscriptionsScreenState();
}

class SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late List<Subscription> subscriptions;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    setState(() {
      subscriptions = HiveService.getSubscriptions()
        ..sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Нет созданных подписок',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите + чтобы создать новую',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    final allSubscriptions = HiveService.getSubscriptions();
    final totalMonthly = allSubscriptions.fold<double>(0, (sum, sub) {
      final price = sub.price.toDouble();
      return sum + (sub.paymentPeriod == 'Год' ? price / 12 : price);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatsScreen(
        subscriptions: allSubscriptions,
        totalMonthly: totalMonthly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadSubscriptions();
          });
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              leading: IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                tooltip: 'Настройки',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ),
                  );
                },
              ),
              actions: [
                if (!widget.showOnlyCategory)
                  IconButton(
                    icon: const Icon(Icons.bar_chart),
                    tooltip: 'Показать статистику',
                    onPressed: () => _showStatistics(context),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text("Мои подписки"),
                titlePadding:
                    const EdgeInsetsDirectional.only(end: 0, bottom: 16),
              ),
            ),
            subscriptions.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final subscription = subscriptions[index];
                        return SubscriptionCard(
                          subscription: subscription,
                          onTap: () =>
                              _navigateToDetail(context, subscription, index),
                        );
                      },
                      childCount: subscriptions.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(
      BuildContext context, Subscription subscription, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionDetailScreen(
          subscription: subscription,
          index: index,
        ),
      ),
    ).then((_) {
      setState(() {
        _loadSubscriptions();
      });
    });
  }
}
