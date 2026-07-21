import 'package:isar/isar.dart';
import 'enums.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;
  
  @enumerated
  TaskPriority priority = TaskPriority.medium;

  int pointsValue = 100; // امتیازی که با انجام این کار نصیب کاربر می‌شود
  
  bool isCompleted = false;
  DateTime? dueDate;
  DateTime? completedAt;

  // فیلد مخصوص برای سیستم "استراحت" که مد نظرت بود
  bool isImportantForRest = false; 

  // واحد اندازه‌گیری (مثلاً عدد، دقیقه، صفحه)
  String unit = "عدد"; 
  double targetValue = 1.0;
  double currentValue = 0.0;

  Task({
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.pointsValue = 100,
    this.dueDate,
    this.isImportantForRest = false,
    this.unit = "عدد",
    this.targetValue = 1.0,
  });
}
