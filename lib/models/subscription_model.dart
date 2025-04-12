import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 0)
class Subscription {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int price;

  @HiveField(2)
  final String paymentPeriod;

  @HiveField(3)
  final String category;

  Subscription({
    required this.name,
    required this.price,
    required this.paymentPeriod,
    required this.category,
  });

  Subscription copyWith({
    String? name,
    int? price,
    String? paymentPeriod,
    String? category,
  }) {
    return Subscription(
      name: name ?? this.name,
      price: price ?? this.price,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      category: category ?? this.category,
    );
  }
}
