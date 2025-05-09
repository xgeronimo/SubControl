import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/hive_service.dart';
import '../widgets/subscription_card.dart';
import 'add_subscription_screen.dart';
import 'subscription_detail_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  final String? categoryName;
  final bool showOnlyCategory;

  const SubscriptionsScreen({
    Key? key,
    this.categoryName,
    this.showOnlyCategory = false,
  }) : super(key: key);

  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late List<Subscription> subscriptions;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    if (widget.showOnlyCategory && widget.categoryName != null) {
      subscriptions =
          HiveService.getSubscriptionsByCategory(widget.categoryName!);
    } else {
      subscriptions = HiveService.getSubscriptions();
    }
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
            SliverList(
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
