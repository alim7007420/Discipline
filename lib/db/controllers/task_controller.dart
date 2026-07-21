import 'package:isar/isar.dart';
import '../database_service.dart';
import '../task.dart';
import '../task_log.dart';
import '../app_settings.dart';
import '../daily_summary.dart';
import '../enums.dart';

class TaskController {
  final Isar _db = DatabaseService().db;

  /// ثبت یا تغییر وضعیت انجام یک تسک
  Future<void> updateTaskStatus(int taskId, int dateKey, int incrementValue) async {
    final task = await _db.tasks.get(taskId);
    if (task == null) return;

    var log = await _db.taskLogs.where().taskIdEqualTo(taskId).dateKeyEqualTo(dateKey).findFirst();
    if (log == null) {
      log = TaskLog(taskId: taskId, dateKey: dateKey);
    }

    int pointsToApply = 0;

    await _db.writeTxn(() async {
      if (task.isTargetBased) {
        log!.currentValue += incrementValue;
        if (log.currentValue >= task.targetValue && !log.isCompleted) {
          log.isCompleted = true;
          pointsToApply = _calculateScore(task, true);
        } else if (log.currentValue < task.targetValue && log.isCompleted) {
          log.isCompleted = false;
          pointsToApply = -_calculateScore(task, true);
        }
      } else {
        log!.isCompleted = !log.isCompleted;
        pointsToApply = _calculateScore(task, log.isCompleted);
      }

      await _db.taskLogs.put(log);
      await _applyPoints(pointsToApply, dateKey);
    });
  }

  int _calculateScore(Task task, bool completed) {
    if (task.type == TaskType.positive) {
      if (completed) {
        return task.points;
      } else {
        return task.hasPenalty ? -(task.points ~/ 2) : 0;
      }
    } else {
      if (!completed) {
        return task.points;
      } else {
        return task.hasPenalty ? -(task.points ~/ 2) : 0;
      }
    }
  }

  Future<void> _applyPoints(int points, int dateKey) async {
    final settings = await _db.appSettings.where().findFirst();
    if (settings != null) {
      settings.totalScore += points;
      if (settings.totalScore < 0) settings.totalScore = 0;
      
      // فرمول گیمیفیکیشن: هر ۱۰۰۰ امتیاز = ۱ سطح
      settings.level = (settings.totalScore ~/ 1000) + 1;
      await _db.appSettings.put(settings);
    }

    var summary = await _db.dailySummary.where().dateKeyEqualTo(dateKey).findFirst();
    if (summary == null) {
      summary = DailySummary(dateKey: dateKey);
    }
    summary.scoreGained += points;
    await _db.dailySummary.put(summary);
  }
}
