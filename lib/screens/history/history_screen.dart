import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/widgets/animated_button.dart';
import 'package:workout_app/widgets/week_calender_widget.dart';

import '../../controllers/history_controller.dart';
import '../../models/models.dart';
import '../../helpers/app_text_style.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE7B3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDE7B3),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'HISTORY',
          style: AppTextStyle.header,
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
            child: Consumer<HistoryController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.history.isEmpty) {
                  return const Center(
                    child: Text(
                      'No workouts\nhave been completed yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 11,
                        color: Colors.black38,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.history.length,
                  itemBuilder: (context, i) => _HistoryCard(
                    history: controller.history[i],
                    onDelete: () => controller.delete(controller.history[i].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── History Card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({required this.history, required this.onDelete});
  final WorkoutHistory history;
  final VoidCallback onDelete;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.history;
    final dateStr = _formatDate(h.completedAt);
    final timeStr = _formatTime(h.completedAt);
    final durationStr = _formatDuration(h.totalDuration);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5F5D),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: const Border(
                bottom: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    h.workoutName,
                    style: const TextStyle(
                      fontFamily: 'RussoOne',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AnimatedButton(
                  onTap: () => setState(() => _expanded = !_expanded),
                  builder: (isPressed) => Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Info row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: dateStr,
                  color: const Color(0xFF3E7CB1),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.access_time,
                  label: timeStr,
                  color: const Color(0xFF3E7CB1),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.timer,
                  label: durationStr,
                  color: const Color(0xFF3E7CB1),
                ),
                const Spacer(),
                // Delete button
                AnimatedButton(
                  onTap: widget.onDelete,
                  builder: (isPressed) => Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.5),
                      boxShadow: isPressed
                          ? []
                          : const [
                              BoxShadow(
                                  color: Colors.black, offset: Offset(0, 4)),
                            ],
                    ),
                    child:
                        const Icon(Icons.delete, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ── Expanded: exercise list ───────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1, color: Colors.black26),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'EXERCISES',
                    style: TextStyle(
                      fontFamily: 'RussoOne',
                      fontSize: 9,
                      letterSpacing: 1,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...h.exercises.map((ex) => _ExerciseResultTile(result: ex)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }
}

// ── Exercise result tile ──────────────────────────────────────────────────────

class _ExerciseResultTile extends StatelessWidget {
  const _ExerciseResultTile({required this.result});
  final ExerciseResult result;

  @override
  Widget build(BuildContext context) {
    final detail = result.type == ExerciseType.repetition
        ? '${result.reps} reps × ${result.sets} sets'
        : '${result.duration?.inSeconds ?? 0}s × ${result.sets} sets';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD1E8E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              result.exerciseName,
              style: const TextStyle(
                fontFamily: 'RussoOne',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              fontFamily: 'RussoOne',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'RussoOne',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
