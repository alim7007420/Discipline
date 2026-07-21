import 'package:isar/isar.dart';
import 'enums.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;

  // نوع عادت: مثبت (امتیازآور) یا منفی (امتیاز کسرکننده)
  @enumerated
  HabitType type = HabitType.positive;

  // فرکانس: روزانه، هفتگی و غیره
  @enumerated
  HabitFrequency frequency = HabitFrequency.daily;

  int pointsPerCompletion = 50; // امتیاز برای هر بار انجام مثبت
  int penaltyPoints = 100; // جریمه برای انجام عادت منفی

  int currentStreak = 0; // زنجیره فعلی (چند روز پشت سر هم)
  int bestStreak = 0; // بهترین رکورد زنجیره

  DateTime? lastCompleted; // آخرین باری که انجام شده

  Habit({
    required this.title,
    this.type = HabitType.positive,
    this.frequency = HabitFrequency.daily,
    this.pointsPerCompletion = 50,
    this.penaltyPoints = 100,
  });
}
