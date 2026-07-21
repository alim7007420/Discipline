import 'package:isar/isar.dart';

part 'growth_action.g.dart';

@collection
class GrowthAction {
  Id id = Isar.autoIncrement;

  int traitId; // شناسه ویژگی مرتبط
  late String actionTitle; // مثل: ۱ ساعت مطالعه تخصصی
  int expGained = 10;
}
