import 'package:isar/isar.dart';

part 'growth_trait.g.dart';

@collection
class GrowthTrait {
  Id id = Isar.autoIncrement;

  late String name; // نام خصلت یا مهارتی که می‌خواهی ارتقا دهی (مثلاً تمرکز، اراده، استقامت)
  String description = "";
  
  int currentLevel = 1; // لول فعلی این خصلت
  int currentXP = 0; // تجربه/امتیاز فعلی در این خصلت
  int xpToNextLevel = 1000; // مقدار امتیاز مورد نیاز برای لول بعدی

  GrowthTrait({
    required this.name,
    this.description = "",
    this.currentLevel = 1,
    this.currentXP = 0,
    this.xpToNextLevel = 1000,
  });
}
