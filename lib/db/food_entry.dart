import 'package:isar/isar.dart';

part 'food_entry.g.dart';

@collection
class FoodEntry {
  Id id = Isar.autoIncrement;

  late String foodName;
  int calories = 0;
  int dateKey; // YYYYMMDD

  FoodEntry({required this.foodName, this.calories = 0, required this.dateKey});
}
