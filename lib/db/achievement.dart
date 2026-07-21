import 'package:isar/isar.dart';

part 'achievement.g.dart';

@collection
class Achievement {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;
  bool isUnlocked = false;
  int? unlockedAtDateKey;
}
