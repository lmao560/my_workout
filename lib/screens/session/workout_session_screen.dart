import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/widgets/week_calender_widget.dart';
import 'package:workout_app/widgets/animated_button.dart';

import '../../controllers/workout_controller.dart';
import '../../services/sound_service.dart';
import '../../screens/session/exercise_active_screen.dart';
import '../../models/models.dart';

class WorkoutSessionScreen extends StatelessWidget {
  const WorkoutSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutController>(
      builder: (context, controller, _) {
        final workout = controller.workout;
        if (workout == null) return const SizedBox.shrink();

        if (controller.isCompleted) return const _CompletedView();

        return Scaffold(
          backgroundColor: const Color(0xFFFDE7B3),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFDE7B3),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: const Text(
              'PLAYING',
              selectionColor: Colors.black,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 26,
                letterSpacing: 1.5,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WeekCalendarWidget(
                  showInfoCard: false,
                  height: 15,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  onDateSelected: (date) {
                    print(date);
                  },
                ),
                // ── Main card ──────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE1AF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title (red)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black, offset: Offset(0, 4)),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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

                        // Exercise list
                        Expanded(
                          child: ListView.builder(
                            itemCount: workout.exercises.length,
                            itemBuilder: (context, i) {
                              final ex = workout.exercises[i];
                              final isActive = controller.session?.isRunning ==
                                      true &&
                                  controller.session?.currentExerciseIndex == i;
                              final isDone =
                                  controller.completedExercises.contains(i);

                              // Ganti bagian ini di ListView.builder:
                              return _SessionExerciseTile(
                                exercise: ex,
                                isActive: isActive,
                                isDone: isDone,
                                progress: isActive
                                    ? controller.currentProgress
                                    : null,
                                onStart: (!isDone)
                                    ? () {
                                        if (!isActive)
                                          controller.startExercise(i);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ChangeNotifierProvider.value(
                                              value: controller,
                                              child:
                                                  const ExerciseActiveScreen(),
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                onCancel:
                                    null, // ← selalu null, cancel ada di screen aktif
                                onNextSet: null, // ← tidak perlu di sini
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── COMPLETE button ────────────────────────────────
                AnimatedButton(
                  onTap: controller.allExercisesCompleted
                      ? () => _onComplete(context, controller)
                      : null,
                  builder: (isPressed) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: controller.allExercisesCompleted
                          ? const Color(0xFFEEFF5E)
                          : const Color(0xFFD4D4AA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: isPressed
                          ? []
                          : const [
                              BoxShadow(
                                  color: Colors.black, offset: Offset(0, 4)),
                            ],
                    ),
                    child: const Center(
                      child: Text(
                        'COMPLETE',
                        style: TextStyle(
                          fontFamily: 'RussoOne',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _onComplete(
    BuildContext context, WorkoutController controller) async {
  final workout = controller.workout!;
  final notStarted = workout.exercises
      .asMap()
      .entries
      .where((e) => !controller.completedExercises.contains(e.key))
      .map((e) => e.value.name)
      .toList();

  // Seharusnya tidak ada yang belum selesai jika allExercisesCompleted,
  // tapi sebagai safety check:
  if (notStarted.isNotEmpty) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFDE7B3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: const Text(
          'Ada exercise belum selesai',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exercise berikut belum diselesaikan:'),
            const SizedBox(height: 8),
            ...notStarted.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 8, color: Color(0xFFE53935)),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            const Text('Tetap selesaikan workout?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Selesaikan',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
  }

  controller.completeSession();
}

// ── Exercise tile dalam session ───────────────────────────────────────────────

class _SessionExerciseTile extends StatelessWidget {
  const _SessionExerciseTile({
    required this.exercise,
    required this.isActive,
    required this.isDone,
    this.progress,
    this.onStart,
    this.onCancel,
    this.onNextSet,
  });

  final Exercise exercise;
  final bool isActive;
  final bool isDone;
  final ExerciseProgress? progress;
  final VoidCallback? onStart;
  final VoidCallback? onCancel;
  final VoidCallback? onNextSet;

  @override
  Widget build(BuildContext context) {
    final isDuration = exercise.type == ExerciseType.duration;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDone ? Colors.grey.shade400 : const Color(0xFF1E93AB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Main row ─────────────────────────────────────────────
          Row(
            children: [
              // Done checkmark
              if (isDone)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child:
                      Icon(Icons.check_circle, size: 18, color: Colors.white),
                ),

              // Name
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    fontFamily: 'RussoOne',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDone ? Colors.white : Colors.black,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),

              // Sets info
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
              const SizedBox(width: 6),

              // Duration icon
              if (isDuration) ...[
                Container(
                  width: 26,
                  height: 31,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5AD18),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.timer, size: 16, color: Colors.black),
                ),
                const SizedBox(width: 2),
              ],

              // Cancel button (when active)
              if (onCancel != null) ...[
                _SmallButton(
                  label: 'Cancel',
                  color: const Color(0xFFE53935),
                  onTap: onCancel!,
                ),
                const SizedBox(width: 6),
              ],

              // Start button
              if (onStart != null)
                AnimatedButton(
                  onTap: onStart,
                  sound: WorkoutSound.startExercise, // ← sound khusus start
                  builder: (isPressed) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF41A67E),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black, width: 1.5),
                      boxShadow: isPressed
                          ? []
                          : const [
                              BoxShadow(
                                  color: Colors.black, offset: Offset(0, 4)),
                            ],
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontFamily: 'RussoOne',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Active state: timer / set info + next set button ──────
          if (isActive && progress != null) ...[
            const SizedBox(height: 8),
            _ActiveInfo(progress: progress!, onNextSet: onNextSet),
          ],
        ],
      ),
    );
  }
}

// ── Active info row (timer / set progress) ────────────────────────────────────

class _ActiveInfo extends StatelessWidget {
  const _ActiveInfo({required this.progress, this.onNextSet});
  final ExerciseProgress progress;
  final VoidCallback? onNextSet;

  @override
  Widget build(BuildContext context) {
    final phase = progress.phase;
    final phaseLabel =
        phase == ExercisePhase.resting ? '💤 Rest' : '🏋️ Active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            'Set ${progress.currentSet}/${progress.exercise.sets}  $phaseLabel',
            style: const TextStyle(
              fontFamily: 'RussoOne',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
          ),

          // Timer
          if (progress.remainingTime != null) ...[
            const SizedBox(width: 8),
            Text(
              _formatTime(progress.remainingTime!),
              style: const TextStyle(
                fontFamily: 'RussoOne',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ],

          const Spacer(),

          // Next set button (repetition only, active phase)
          if (onNextSet != null)
            AnimatedButton(
              onTap: onNextSet,
              builder: (isPressed) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEFF5E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: isPressed
                      ? []
                      : const [
                          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                        ],
                ),
                child: const Text(
                  'Next Set',
                  style: TextStyle(
                    fontFamily: 'RussoOne',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    final s = d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}

// ── Small button ──────────────────────────────────────────────────────────────

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      builder: (isPressed) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: isPressed
              ? []
              : const [
                  BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'RussoOne',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _RetroPhotoFrame extends StatelessWidget {
  const _RetroPhotoFrame({
    required this.imagePath,
    required this.label,
    this.width = 220,
  });

  final String imagePath;
  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(6, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top bar retro ────────────────────────────────────
          Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC107),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF347433),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // ── Photo ────────────────────────────────────────────
          Container(
            height: 160,
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF4DC8D0),
                  child: const Center(
                    child: Icon(Icons.fitness_center,
                        size: 60, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // ── Label strip ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'RussoOne',
                color: Color(0xFFF4F754),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completed view ────────────────────────────────────────────────────────────

class _CompletedView extends StatelessWidget {
  const _CompletedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE7B3),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Retro frame ──────────────────────────────────
              _RetroPhotoFrame(
                imagePath: 'assets/images/workout_complete.jpg',
                label: 'WORKOUT COMPLETE!',
                width: 260,
              ),
              const SizedBox(height: 32),

              // ── Selesai button ────────────────────────────────
              AnimatedButton(
                onTap: () => Navigator.of(context).pop(),
                builder: (isPressed) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F754),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: isPressed
                        ? []
                        : const [
                            BoxShadow(
                                color: Colors.black, offset: Offset(0, 4)),
                          ],
                  ),
                  child: const Center(
                    child: Text(
                      'DONE',
                      style: TextStyle(
                        fontFamily: 'RussoOne',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
