import 'package:flutter/material.dart';
import 'db/database_service.dart';
import 'views/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // مقداردهی اولیه دیتابیس Isar
  await DatabaseService().init();

  runApp(const DisciplineApp());
}

class DisciplineApp extends StatelessWidget {
  const DisciplineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discipline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.deepOrangeAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepOrangeAccent,
          secondary: Colors.amber,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const DashboardView(),
    );
  }
}
