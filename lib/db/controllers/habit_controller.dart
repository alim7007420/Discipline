import 'package:isar/isar.dart';
import '../database_service.dart';
import '../habit.dart';
import '../habit_log.dart';
import '../app_settings.dart';
import '../daily_summary.dart';

class HabitController {
  final Isar _db = DatabaseService().db;

  /// تکمیل یا لغو یک عادت و محاسبه خودکار استریک
  Future<void> toggleHabit(int habitId, int dateKey) async {
    final habit = await _db.habits.get(habitId);
    if (habit == null) return;

    var log = await _db.habitLogs.where().habitIdEqualTo(habitId).dateKeyEqualTo(dateKey).findFirst();
    if (log == null) {
      log = HabitLog(habitId: habitId, dateKey: dateKey);
    }

    log.isCompleted = !log.isCompleted;
    int pointsToApply = log.isCompleted ? habit.points : -habit.points;

    await _db.writeTxn(() async {
      await _db.habitLogs.put(log!);

      if (log.isCompleted) {
        habit.currentStreak += 1;
        if (habit.currentStreak > habit.longestStreak) {
          habit.longestStreak = habit.currentStreak;
        }
      } else {
        habit.currentStreak = habit.currentStreak > 0 ? habit.currentStreak - 1 : 0;
      }
      await _db.habits.put(habit);

      // به‌روزرسانی لول و ثبت امتیاز
      final settings = await _db.appSettings.where().findFirst();
      if (settings != null) {
        settings.totalScore += pointsToApply;
        if (settings.totalScore < 0) settings.totalScore = 0;
        settings.level = (settings.totalScore ~/ 1000) + 1;
        await _db.appSettings.put(settings);
      }

      var summary = await _db.dailySummary.where().dateKeyEqualTo(dateKey).findFirst();
      if (summary == null) {
        summary = DailySummary(dateKey: dateKey);
      }
      summary.scoreGained += pointsToApply;
      await _db.dailySummary.put(summary);
    });
  }
}
