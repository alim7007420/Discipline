import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app_settings.dart';
import 'daily_summary.dart';
import 'task.dart';
import 'task_log.dart';
import 'habit.dart';
import 'habit_log.dart';
import 'growth_trait.dart';
import 'growth_action.dart';
import 'workout.dart';
import 'bank_account.dart';
import 'transaction_record.dart';
import 'shopping_item.dart';
import 'food_entry.dart';
import 'achievement.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Isar db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    db = await Isar.open(
      [
        AppSettingsSchema,
        DailySummarySchema,
        TaskSchema,
        TaskLogSchema,
        HabitSchema,
        HabitLogSchema,
        GrowthTraitSchema,
        GrowthActionSchema,
        WorkoutPlanSchema,
        WorkoutSessionSchema,
        WorkoutExerciseSchema,
        ExerciseSetSchema,
        BankAccountSchema,
        TransactionRecordSchema,
        ShoppingItemSchema,
        FoodEntrySchema,
        AchievementSchema,
      ],
      directory: dir.path,
    );

    // ساخت تنظیمات اولیه در صورت خالی بودن دیتابیس
    if (await db.appSettings.count() == 0) {
      await db.writeTxn(() async {
        await db.appSettings.put(AppSettings());
      });
    }
  }
}
