import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 0)
class Subscription {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int price;
  @HiveField(3)
  final String paymentPeriod;
  @HiveField(4)
  final String category;
  @HiveField(5)
  final DateTime nextPaymentDate;
  @HiveField(6)
  final String note;
  @HiveField(7)
  final int notificationDays;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.paymentPeriod,
    required this.category,
    required this.nextPaymentDate,
    required this.note,
    required this.notificationDays,
  });

  Subscription copyWith({
    String? id,
    String? name,
    int? price,
    String? paymentPeriod,
    String? category,
    DateTime? nextPaymentDate,
    String? note,
    int? notificationDays,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      category: category ?? this.category,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      note: note ?? this.note,
      notificationDays: notificationDays ?? this.notificationDays,
    );
  }
}
