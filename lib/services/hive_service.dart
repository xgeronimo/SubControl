import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/subscription_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SubscriptionAdapter());
    await Hive.openBox<Subscription>('subscriptions');
  }

  static Box<Subscription> getSubscriptionBox() {
    return Hive.box<Subscription>('subscriptions');
  }

  static void addSubscription(Subscription subscription) {
    final box = getSubscriptionBox();
    box.add(subscription);
  }

  static List<Subscription> getSubscriptions() {
    final box = getSubscriptionBox();
    return box.values.toList();
  }

  static void deleteSubscription(int index) {
    final box = getSubscriptionBox();
    box.deleteAt(index);
  }
}
