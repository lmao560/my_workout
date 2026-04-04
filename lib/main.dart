import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/screens/history/history_screen.dart';

import 'controllers/schedule_controller.dart';
import 'controllers/workout_builder_controller.dart';
import 'controllers/workout_list_controller.dart';
import 'repository/hive_repository.dart';
import 'controllers/history_controller.dart';
import 'screens/builder/workout_list_screen.dart';

final workoutRepo = HiveWorkoutRepository();
final planRepo = HiveWorkoutPlanRepository();
final historyRepo = HiveHistoryRepository();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('workouts');
  await Hive.openBox('plans');
  await Hive.openBox('history');

  debugPrint('🚀 HIVE READY - workouts: ${Hive.box('workouts').length}');

  // ── Repositories (swap to Hive/` SQLite here, nothing else changes) ──────────
  runApp(
    MultiProvider(
      providers: [
        // Workout list
        ChangeNotifierProvider(
          create: (_) => WorkoutListController(repository: workoutRepo),
        ),
        // Workout builder (shared, reset on each use)
        ChangeNotifierProvider(
          create: (_) => WorkoutBuilderController(repository: workoutRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryController(repository: historyRepo),
        ),
        // Schedule
        ChangeNotifierProvider(
          create: (_) => ScheduleController(
            planRepository: planRepo,
            workoutRepository: workoutRepo,
          ),
        ),
      ],
      child: const WorkoutApp(),
    ),
  );
}

// ── App root ──────────────────────────────────────────────────────────────────

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        fontFamily: 'RussoOne',
      ),
      home: const MainShell(),
    );
  }
}

// ── Bottom nav shell ──────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    WorkoutListScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE7B3),
      body: _screens[_index],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE1AF), // 🔥 warna utama
          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: Colors.black,
            width: 2,
          ),

          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 4), // shadow retro
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.home,
              label: "HOME",
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              icon: Icons.history,
              label: "HISTORY",
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: Colors.black,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.russoOne(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
