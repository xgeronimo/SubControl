import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/subscription_model.dart';
import '../models/category_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    //await Hive.close();
    //await Hive.deleteBoxFromDisk('subscriptions');
    //await Hive.deleteBoxFromDisk('categories');

    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(CategoryAdapter());

    await Hive.openBox<Subscription>('subscriptions');
    await Hive.openBox<Category>('categories');
  }

  static Box<Subscription> getSubscriptionBox() =>
      Hive.box<Subscription>('subscriptions');
  static Box<Category> getCategoryBox() => Hive.box<Category>('categories');

  static void addSubscription(Subscription subscription) {
    getSubscriptionBox().add(subscription);
  }

  static void addCategory(String name) {
    getCategoryBox().add(Category(name: name));
  }

  static List<Subscription> getSubscriptions() =>
      getSubscriptionBox().values.toList();

  static List<Subscription> getSubscriptionsByCategory(String category) {
    return getSubscriptionBox()
        .values
        .where((sub) => sub.category == category)
        .toList();
  }

  static void deleteSubscription(int index) {
    getSubscriptionBox().deleteAt(index);
  }

  static void updateSubscription(int index, Subscription newSubscription) {
    getSubscriptionBox().putAt(index, newSubscription);
    //getSubscriptionBox().listenable().notifyListeners();
  }

  static List<Category> getCategories() => getCategoryBox().values.toList();

  static void deleteCategory(int index) {
    getCategoryBox().deleteAt(index);
  }
}
