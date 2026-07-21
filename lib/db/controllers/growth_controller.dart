import 'package:isar/isar.dart';
import '../database_service.dart';
import '../growth_trait.dart';
import '../growth_action.dart';

class GrowthController {
  final Isar _db = DatabaseService().db;

  /// انجام اقدام توسعه فردی و اضافه شدن تجربه (XP) به شاخص مرتبط
  Future<void> performGrowthAction(int actionId) async {
    final action = await _db.growthActions.get(actionId);
    if (action == null) return;

    final trait = await _db.growthTraits.get(action.traitId);
    if (trait == null) return;

    await _db.writeTxn(() async {
      trait.experiencePoints += action.expGained;
      await _db.growthTraits.put(trait);
    });
  }
}
