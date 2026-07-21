import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../db/database_service.dart';
import '../db/habit.dart';
import '../db/habit_log.dart';
import '../db/controllers/habit_controller.dart';

class HabitsView extends StatefulWidget {
  const HabitsView({super.key});

  @override
  State<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<HabitsView> {
  final Isar _db = DatabaseService().db;
  final HabitController _controller = HabitController();

  List<Habit> _habits = [];
  Map<int, HabitLog> _logs = {};
  int _todayKey = 0;

  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayKey = int.parse(
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _db.habits.where().findAll();
    final logs = await _db.habitLogs.where().dateKeyEqualTo(_todayKey).findAll();
    
    final Map<int, HabitLog> logMap = {for (var log in logs) log.habitId: log};

    setState(() {
      _habits = habits;
      _logs = logMap;
    });
  }

  Future<void> _createHabit() async {
    if (_titleController.text.trim().isEmpty) return;

    final newHabit = Habit()..title = _titleController.text.trim();

    await _db.writeTxn(() async {
      await _db.habits.put(newHabit);
    });

    _titleController.clear();
    _loadHabits();
    if (mounted) Navigator.pop(context);
  }

  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 16, right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'عنوان عادت جدید'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createHabit,
                child: const Text('افزودن عادت'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عادت‌ها')),
      body: ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          final log = _logs[habit.id];
          final isDone = log?.isCompleted ?? false;

          return ListTile(
            title: Text(habit.title),
            subtitle: Text('شعله فعلی: 🔥 ${habit.currentStreak} | بیشترین: ${habit.longestStreak}'),
            trailing: IconButton(
              icon: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? Colors.green : Colors.grey,
              ),
              onPressed: () async {
                await _controller.toggleHabit(habit.id, _todayKey);
                _loadHabits();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
