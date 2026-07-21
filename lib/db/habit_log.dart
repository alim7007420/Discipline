import 'package:isar/isar.dart';

part 'habit_log.g.dart';

@collection
class HabitLog {
  Id id = Isar.autoIncrement;

  int habitId; // شناسه عادت مربوطه
  DateTime timestamp; // زمان ثبت
  bool isSuccess; // آیا ثبت موفق بوده یا وقوع عادت منفی
  int pointsImpact; // میزان امتیاز اضافه یا کسر شده
  String? note; // یادداشت کوتاه در صورت نیاز

  HabitLog({
    required this.habitId,
    required this.timestamp,
    this.isSuccess = true,
    this.pointsImpact = 0,
    this.note,
  });
}
