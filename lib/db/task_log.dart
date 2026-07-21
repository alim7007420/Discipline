import 'package:isar/isar.dart';

part 'task_log.g.dart';

@collection
class TaskLog {
  Id id = Isar.autoIncrement;

  int taskId; // شناسه تسکی که انجام شده
  DateTime timestamp; // زمان دقیق ثبت فعالیت
  double progressMade; // مقدار پیشرفت ثبت شده در این نوبت
  int pointsEarned; // امتیاز کسب شده در این نوبت

  TaskLog({
    required this.taskId,
    required this.timestamp,
    this.progressMade = 0.0,
    this.pointsEarned = 0,
  });
}
