import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../db/database_service.dart';
import '../db/app_settings.dart';
import '../db/daily_summary.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final Isar _db = DatabaseService().db;
  AppSettings? _settings;
  DailySummary? _todaySummary;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final settings = await _db.appSettings.where().findFirst();
    final now = DateTime.now();
    final todayKey = int.parse(
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");

    var summary = await _db.dailySummary.where().dateKeyEqualTo(todayKey).findFirst();
    if (summary == null) {
      summary = DailySummary(dateKey: todayKey, isRestDay: settings?.restDays[now.weekday % 7] ?? false);
      await _db.writeTxn(() => _db.dailySummary.put(summary!));
    }

    setState(() {
      _settings = settings;
      _todaySummary = summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = _settings?.level ?? 1;
    final totalScore = _settings?.totalScore ?? 0;
    final progress = (totalScore % 1000) / 1000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('دیسیپلین'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت گیمیفیکیشن و سطح علی
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'سطح علی: $level',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    Text('$totalScore / ${level * 1000} امتیاز کل'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // وضعیت روز جاری
            Card(
              color: Colors.blueGrey[50],
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blueGrey),
                title: Text('روز استراحت: ${_todaySummary?.isRestDay == true ? "بله" : "خیر"}'),
                subtitle: Text('امتیاز کسب شده امروز: ${_todaySummary?.scoreGained ?? 0}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
