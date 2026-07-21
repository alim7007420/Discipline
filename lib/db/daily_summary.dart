import 'package:isar/isar.dart';

part 'daily_summary.g.dart';

@collection
class DailySummary {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  DateTime date; // تاریخ روز (بدون ساعت)

  int totalPoints = 0; // مجموع امتیازات کسب شده در این روز
  int completedTasks = 0; // تعداد کارهای انجام شده
  int completedHabits = 0; // تعداد عادت‌های موفق
  
  double calorieConsumed = 0; // کالری مصرفی
  double waterIntake = 0; // میزان آب مصرفی (لیتر)
  
  String mood = "Neutral"; // وضعیت روحی روزانه
  String dailyNote = ""; // یادداشت روزانه

  DailySummary({
    required this.date,
    this.totalPoints = 0,
    this.completedTasks = 0,
    this.completedHabits = 0,
    this.calorieConsumed = 0,
    this.waterIntake = 0,
    this.mood = "Neutral",
    this.dailyNote = "",
  });
}
