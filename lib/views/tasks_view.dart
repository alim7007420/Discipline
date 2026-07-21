import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../db/database_service.dart';
import '../db/task.dart';
import '../db/task_log.dart';
import '../db/enums.dart';
import '../db/controllers/task_controller.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final Isar _db = DatabaseService().db;
  final TaskController _controller = TaskController();

  List<Task> _tasks = [];
  Map<int, TaskLog> _logs = {};
  int _todayKey = 0;

  final _titleController = TextEditingController();
  TaskType _selectedType = TaskType.positive;
  TaskPeriod _selectedPeriod = TaskPeriod.daily;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayKey = int.parse(
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _db.tasks.where().findAll();
    final logs = await _db.taskLogs.where().dateKeyEqualTo(_todayKey).findAll();
    
    final Map<int, TaskLog> logMap = {for (var log in logs) log.taskId: log};

    setState(() {
      _tasks = tasks;
      _logs = logMap;
    });
  }

  Future<void> _createTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final newTask = Task()
      ..title = _titleController.text.trim()
      ..type = _selectedType
      ..period = _selectedPeriod;

    await _db.writeTxn(() async {
      await _db.tasks.put(newTask);
    });

    _titleController.clear();
    _loadTasks();
    if (mounted) Navigator.pop(context);
  }

  void _showAddTaskSheet() {
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
                decoration: const InputDecoration(labelText: 'عنوان وظیفه'),
              ),
              DropdownButtonFormField<TaskType>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: TaskType.positive, child: Text('مثبت')),
                  DropdownMenuItem(value: TaskType.negative, child: Text('منفی')),
                ],
                onChanged: (val) => _selectedType = val!,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createTask,
                child: const Text('افزودن'),
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
      appBar: AppBar(title: const Text('وظایف روزانه')),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final log = _logs[task.id];
          final isDone = log?.isCompleted ?? false;

          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.type == TaskType.positive ? 'مثبت' : 'منفی'),
            trailing: Checkbox(
              value: isDone,
              onChanged: (_) async {
                await _controller.updateTaskStatus(task.id, _todayKey, 1);
                _loadTasks();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
