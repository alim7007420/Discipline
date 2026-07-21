import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  int currentXp = 0;
  int userLevel = 1;
  String caricatureRank = 'سرباز پیاده';
  bool isDarkTheme = true;
  DateTime? lastLoginDate;
}
