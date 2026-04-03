import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workout_app/widgets/week_calender_widget.dart';
import 'package:workout_app/widgets/animated_button.dart';

import '../../controllers/workout_controller.dart';
import '../../models/models.dart';

class ExerciseActiveScreen extends StatelessWidget {
  const ExerciseActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutController>(
      builder: (context, controller, _) {
        final progress = controller.currentProgress;
        final workout = controller.workout;

        if (progress?.phase == ExercisePhase.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).pop();
          });
        }

        if (progress == null || workout == null) {
          return const SizedBox.shrink();
        }

        final phase = progress.phase;
        final isResting = phase == ExercisePhase.resting;
        final isRepetition = progress.exercise.type == ExerciseType.repetition;

        // Sisa set: saat active = belum dikurangi, saat rest = sudah dikurangi
        final remainingSets = isResting
            ? progress.exercise.sets - progress.currentSet
            : progress.exercise.sets - (progress.currentSet - 1);

        return Scaffold(
          backgroundColor: const Color(0xFFFDE7B3),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFDE7B3),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFFFDE7B3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    title: Text(
                      'Keluar dari exercise?',
                      style: GoogleFonts.russoOne(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    content: const Text(
                      'Progress set yang sedang berjalan akan hilang.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Lanjutkan'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Keluar',
                          style: GoogleFonts.russoOne(color: Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  controller.cancelExercise();
                  Navigator.of(context).pop();
                }
              },
            ),
            centerTitle: true,
            title: Text(
              'STARTING ',
              selectionColor: Colors.black,
              style: GoogleFonts.pressStart2p(
                fontSize: 26,
                letterSpacing: 1.5,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WeekCalendarWidget(
                      showInfoCard: false,
                      height: 15,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      onDateSelected: (date) {
                        print(date);
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE1AF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black, offset: Offset(0, 4)),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Workout title (red) ──────────────────
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 4)),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Text(
                                workout.name,
                                style: GoogleFonts.russoOne(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Exercise name (teal) ─────────────────
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E93AB),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 4)),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Text(
                                isRepetition
                                    ? '${progress.exercise.name}  ${progress.exercise.reps} × ${progress.exercise.sets}'
                                    : '${progress.exercise.name}  × ${progress.exercise.sets}',
                                style: GoogleFonts.russoOne(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Konten tengah ─────────────────────────
                            if (phase == ExercisePhase.waitingFinish)
                              _CelebrationView(exercise: progress.exercise)
                            else ...[
                              if (progress.remainingTime != null)
                                _FlipTimerDisplay(
                                  remaining: progress.remainingTime!,
                                  isResting: isResting,
                                ),
                              const SizedBox(height: 24),
                              _RemainingSetsBadge(
                                remainingSets: remainingSets,
                                isResting: isResting,
                                totalSets: progress.exercise.sets,
                              ),
                            ],

                            const SizedBox(height: 24),

                            // ── Action button ─────────────────────────
                            _ActionButton(
                              progress: progress,
                              remainingSets: remainingSets,
                              onNextSet: controller.onNextSet,
                              onFinish: controller.finishExercise,
                              onSkipRest: controller.skipRest,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ), // SingleChildScrollView
        ); // Scaffold
      }, // Consumer builder
    ); // Consumer
  } // build()
} // ExerciseActiveScreen

// ── Remaining sets badge ──────────────────────────────────────────────────────

class _RemainingSetsBadge extends StatelessWidget {
  const _RemainingSetsBadge({
    required this.remainingSets,
    required this.isResting,
    required this.totalSets,
  });

  final int remainingSets;
  final bool isResting;
  final int totalSets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Sisa Set',
          style: GoogleFonts.russoOne(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSets, (i) {
            // i=0 adalah set terakhir (paling kanan)
            // Dot menyala jika index dari kanan < remainingSets
            final isActive = (totalSets - 1 - i) < remainingSets;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isActive
                    ? (isResting
                        ? const Color(0xFF1E93AB)
                        : const Color(0xFF4DC8D0))
                    : const Color(0xFFBFC9D1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '$remainingSets',
          style: GoogleFonts.russoOne(
            fontWeight: FontWeight.bold,
            fontSize: 48,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _CelebrationView extends StatefulWidget {
  const _CelebrationView({required this.exercise});
  final Exercise exercise;

  @override
  State<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<_CelebrationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Retro photo frame ──────────────────────────────────
          ScaleTransition(
            scale: _scaleAnim,
            child: _RetroPhotoFrame(
              imagePath: 'assets/images/workout_done.jpg',
              label: 'GREAT JOB!',
            ),
          ),
          const SizedBox(height: 16),

          // ── Stats summary ──────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E93AB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                ],
              ),
              child: Text(
                widget.exercise.type == ExerciseType.repetition
                    ? '${widget.exercise.sets} sets  ×  ${widget.exercise.reps} reps selesai!'
                    : '${widget.exercise.sets} sets  ×  ${widget.exercise.duration!.inSeconds}s selesai!',
                style: GoogleFonts.russoOne(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
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
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(0, 4)),
              ],
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
              style: GoogleFonts.russoOne(
                color: Color(0xFFFFC107),
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

// ── Flip timer display ────────────────────────────────────────────────────────

class _FlipTimerDisplay extends StatelessWidget {
  const _FlipTimerDisplay({
    required this.remaining,
    required this.isResting,
  });

  final Duration remaining;
  final bool isResting;

  @override
  Widget build(BuildContext context) {
    final s = remaining.inSeconds;
    final hours = (s ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (s % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isResting
            ? const Color(0xFFE62727) // kuning saat rest
            : const Color(0xFFE53935), // merah saat active
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FlipCard(value: hours),
          const SizedBox(width: 8),
          _FlipCard(value: minutes),
          const SizedBox(width: 8),
          _FlipCard(value: seconds),
        ],
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(
          value,
          style: GoogleFonts.russoOne(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 36,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.progress,
    required this.remainingSets,
    required this.onNextSet,
    required this.onFinish,
    required this.onSkipRest,
  });

  final ExerciseProgress progress;
  final int remainingSets;
  final VoidCallback onNextSet;
  final VoidCallback onFinish;
  final VoidCallback onSkipRest;
  @override
  Widget build(BuildContext context) {
    final phase = progress.phase;
    final isResting = phase == ExercisePhase.resting;
    final isRepetition = progress.exercise.type == ExerciseType.repetition;
    final isDone = phase == ExercisePhase.waitingFinish;

    // Label dan warna tombol
    final String label;
    final Color color;
    final bool tappable;

    if (isDone) {
      label = 'FINISH';
      color = const Color(0xFFEEFF5E);
      tappable = true;
    } else if (isResting) {
      // Tampilkan dua tombol: REST timer + SKIP
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // REST label (non-tappable)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEFF5E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Center(
              child: Text(
                'REST...',
                style: GoogleFonts.russoOne(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // SKIP REST tombol
          AnimatedButton(
            onTap: onSkipRest,
            builder: (isPressed) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4DC8D0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: isPressed
                    ? []
                    : const [
                        BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                      ],
              ),
              child: Center(
                child: Text(
                  'SKIP REST',
                  style: GoogleFonts.russoOne(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (isRepetition) {
      label = 'NEXT SET';
      color = const Color(0xFF06923E);
      tappable = true;
    } else {
      label = 'RUNNING...';
      color = const Color(0xFF4DC8D0);
      tappable = false; // duration auto
    }

    return AnimatedButton(
      onTap: tappable ? (isDone ? onFinish : onNextSet) : null,
      builder: (isPressed) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: (tappable && !isPressed)
              ? const [BoxShadow(color: Colors.black, offset: Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.russoOne(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
