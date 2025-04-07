import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String name;

  Category({
    required this.name,
  });
}
