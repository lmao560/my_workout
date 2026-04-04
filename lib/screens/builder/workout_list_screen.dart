import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/widgets/week_calender_widget.dart';
import 'package:workout_app/widgets/animated_button.dart';
import 'package:workout_app/main.dart';

import '../../controllers/workout_controller.dart';
import '../../controllers/workout_list_controller.dart';
import '../../controllers/workout_builder_controller.dart';
import '../../models/models.dart';
import '../session/workout_session_screen.dart';
import '../../helpers/app_text_style.dart';
import 'workout_builder_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutListController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDE7B3),
      appBar: AppBar(
        backgroundColor: Color(0xFFFDE7B3),
        centerTitle: true,
        title: Text(
          'WELCOME',
          style: AppTextStyle.header,
        ),
      ),
      floatingActionButton: AnimatedButton(
        onTap: () => _openBuilder(context),
        builder: (isPressed) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFE62727),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: isPressed
                ? []
                : const [
                    BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                  ],
          ),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          WeekCalendarWidget(
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onDateSelected: (date) {
              print(date);
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Consumer<WorkoutListController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.workouts.isEmpty) {
                  return Center(
                    child: Text('No workouts yet.\nTap + to create one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          color: Colors.black.withOpacity(0.3),
                          fontSize: 12,
                          letterSpacing: 1,
                        )),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.workouts.length,
                    itemBuilder: (context, i) =>
                        _WorkoutTile(workout: controller.workouts[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openBuilder(BuildContext context, {Workout? workout}) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => WorkoutBuilderScreen(existing: workout),
        ))
        .then((_) => context.read<WorkoutListController>().refresh());
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF06923E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: nama + eye icon ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  workout.name,
                  style: const TextStyle(
                    fontFamily: 'RussoOne',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              // Eye button
              AnimatedButton(
                onTap: () => _showPreview(context),
                builder: (isPressed) => Container(
                  width: 34,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5AD18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: isPressed
                        ? []
                        : const [
                            BoxShadow(
                                color: Colors.black, offset: Offset(0, 4)),
                          ],
                  ),
                  child: const Icon(Icons.remove_red_eye,
                      size: 18, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Action buttons ───────────────────────────────────────

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _TileButton(
                    label: 'Edit',
                    color: const Color(0xFFC0F21B),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (_) =>
                              WorkoutBuilderScreen(existing: workout),
                        ))
                        .then((_) =>
                            context.read<WorkoutListController>().refresh()),
                  ),
                  const SizedBox(width: 4),
                  _TileButton(
                    label: 'Copy',
                    color: const Color(0xFF9C27B0),
                    onTap: () => _duplicateWorkout(context),
                  ),
                  const SizedBox(width: 4),
                  _TileButton(
                    label: 'Delete',
                    color: const Color(0xFFF82D30),
                    onTap: () => _confirmDelete(context),
                  ),
                  const SizedBox(width: 4),
                  _TileButton(
                    label: 'Play',
                    color: const Color(0xFF41A67E), // teal
                    onTap: () => _startSession(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _WorkoutPreviewCard(workout: workout),
      ),
    );
  }

  void _duplicateWorkout(BuildContext context) {
    context.read<WorkoutBuilderController>().loadForDuplicate(workout);
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => const WorkoutBuilderScreen(),
        ))
        .then((_) => context.read<WorkoutListController>().refresh());
  }

  void _startSession(BuildContext context) {
    final sessionController = WorkoutController(
      historyRepository: historyRepo,
    )..loadWorkout(workout);
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: sessionController,
            child: const WorkoutSessionScreen(),
          ),
        ))
        .then((_) => sessionController.dispose());
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus workout?'),
        content: Text('Hapus "${workout.name}"? Tidak bisa dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<WorkoutListController>().delete(workout.id);
    }
  }
}

// ── Tile action button ────────────────────────────────────────────────────────

class _TileButton extends StatelessWidget {
  const _TileButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedButton(
        onTap: onTap,
        builder: (isPressed) => Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: isPressed
                ? []
                : const [
                    BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'RussoOne',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Preview card (dialog) ─────────────────────────────────────────────────────

class _WorkoutPreviewCard extends StatelessWidget {
  const _WorkoutPreviewCard({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDE7B3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title (red)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE62727),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              workout.name,
              style: const TextStyle(
                fontFamily: 'RussoOne',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Exercise list (read-only)
          ...workout.exercises.map((ex) => _PreviewExerciseTile(exercise: ex)),

          const SizedBox(height: 12),

          // Close button
          AnimatedButton(
            onTap: () => Navigator.of(context).pop(),
            builder: (isPressed) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE62727),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: isPressed
                    ? []
                    : const [
                        BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                      ],
              ),
              child: const Center(
                child: Text(
                  'CLOSE',
                  style: TextStyle(
                    fontFamily: 'RussoOne',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Preview exercise tile (read-only, sama style dengan builder) ──────────────

class _PreviewExerciseTile extends StatelessWidget {
  const _PreviewExerciseTile({required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final isDuration = exercise.type == ExerciseType.duration;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E93AB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              exercise.name,
              style: const TextStyle(
                fontFamily: 'RussoOne',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            exercise.type == ExerciseType.repetition
                ? '${exercise.reps} × ${exercise.sets}'
                : '× ${exercise.sets}',
            style: const TextStyle(
              fontFamily: 'RussoOne',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          if (isDuration) ...[
            const SizedBox(width: 8),
            Container(
              width: 26,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xFFF5AD18), // kuning
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.timer, size: 16, color: Colors.black),
            ),
          ]
        ],
      ),
    );
  }
}
