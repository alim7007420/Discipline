import 'package:isar/isar.dart';

part 'workout.g.dart';

@collection
class WorkoutPlan {
  Id id = Isar.autoIncrement;
  late String planName; // مثل: برنامه فول بادی شنبه
}

@collection
class WorkoutSession {
  Id id = Isar.autoIncrement;
  int planId;
  int dateKey; // YYYYMMDD
  String note = '';

  WorkoutSession({required this.planId, required this.dateKey, this.note = ''});
}

@collection
class WorkoutExercise {
  Id id = Isar.autoIncrement;
  int sessionId;
  late String exerciseName;
}

@collection
class ExerciseSet {
  Id id = Isar.autoIncrement;
  int exerciseId;
  int setNumber = 1;
  double weight = 0.0;
  int reps = 0;
  int restSeconds = 60; // زمان استراحت بعد از این ست
}
