import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/services/sound_service.dart';
import 'package:workout_app/widgets/animated_button.dart';
import 'package:workout_app/widgets/week_calender_widget.dart';

import '../../controllers/workout_builder_controller.dart';
import '../../controllers/workout_list_controller.dart';
import '../../models/models.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  const WorkoutBuilderScreen({super.key, this.existing});
  final Workout? existing;

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final names = context.read<WorkoutListController>().workoutNames;
      context.read<WorkoutBuilderController>().setExistingNames(names);
      if (widget.existing != null) {
        context.read<WorkoutBuilderController>().loadForEdit(widget.existing!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutBuilderController>(
      builder: (context, controller, _) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final hasChanges =
                controller.name.isNotEmpty || controller.exercises.isNotEmpty;
            if (!hasChanges) {
              Navigator.of(context).pop();
              return;
            }
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFFFDE7B3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                title: const Text(
                  'Keluar?',
                  style: TextStyle(
                      fontFamily: 'RussoOne', fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'Perubahan yang belum disimpan akan hilang.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Keluar',
                      style: TextStyle(
                          fontFamily: 'RussoOne',
                          fontSize: 16,
                          color: const Color(0xFFE53935)),
                    ),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
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
                'WORKOUT',
                style: TextStyle(
                    fontFamily: 'PressStart2P', fontSize: 26, letterSpacing: 2),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight -
                    8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WeekCalendarWidget(
                      showInfoCard: false,
                      height: 15,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      onDateSelected: (_) {},
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
                            // Name field
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
                              child: TextFormField(
                                initialValue: controller.name,
                                style: const TextStyle(
                                  fontFamily: 'RussoOne',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Title',
                                  hintStyle: TextStyle(
                                    fontFamily: 'RussoOne',
                                    color: Colors.white70,
                                    fontSize: 20,
                                    letterSpacing: 1.5,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                onChanged: controller.setName,
                              ),
                            ),

                            // Name error
                            Consumer<WorkoutBuilderController>(
                              builder: (_, ctrl, __) {
                                final error = ctrl.nameError;
                                if (error == null)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6, left: 4),
                                  child: Text(
                                    error,
                                    style: const TextStyle(
                                      fontFamily: 'RussoOne',
                                      color: Color(0xFFE53935),
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Exercise list
                            Expanded(
                              child: controller.exercises.isEmpty
                                  ? const SizedBox.shrink()
                                  : ReorderableListView.builder(
                                      shrinkWrap: true,
                                      itemCount: controller.exercises.length,
                                      onReorder: controller.reorderExercises,
                                      proxyDecorator: (child, _, __) => child,
                                      itemBuilder: (context, i) {
                                        final ex = controller.exercises[i];
                                        return _ExerciseTile(
                                          key: ValueKey(ex.id),
                                          exercise: ex,
                                          onEdit: () => _openExerciseForm(
                                              context, controller,
                                              existing: ex),
                                          onDelete: () =>
                                              controller.removeExercise(ex.id),
                                        );
                                      },
                                    ),
                            ),

                            // Add exercise button
                            AnimatedButton(
                              onTap: () =>
                                  _openExerciseForm(context, controller),
                              builder: (isPressed) => Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5D79E),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                  boxShadow: isPressed
                                      ? []
                                      : const [
                                          BoxShadow(
                                              color: Colors.black,
                                              offset: Offset(0, 4))
                                        ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        color: Colors.black, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      'Add Exercise',
                                      style: TextStyle(
                                        fontFamily: 'RussoOne',
                                        color: Colors.black,
                                        fontSize: 14,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Exercise count error
                    Consumer<WorkoutBuilderController>(
                      builder: (_, ctrl, __) {
                        final error = ctrl.exerciseCountError;
                        if (error == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFE53935), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Color(0xFFE53935), size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  error,
                                  style: const TextStyle(
                                    fontFamily: 'RussoOne',
                                    color: Color(0xFFE53935),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // CREATE / UPDATE button
                    AnimatedButton(
                      onTap: controller.canSave && !controller.isSaving
                          ? () => _save(context, controller)
                          : null,
                      sound: WorkoutSound.create,
                      builder: (isPressed) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: controller.canSave
                              ? const Color(0xFFEEFF5E)
                              : const Color(0xFFD4D4AA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: isPressed
                              ? []
                              : const [
                                  BoxShadow(
                                      color: Colors.black, offset: Offset(0, 4))
                                ],
                        ),
                        child: Center(
                          child: controller.isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  widget.existing == null ? 'CREATE' : 'UPDATE',
                                  style: const TextStyle(
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

                    if (controller.error != null)
                      Text(controller.error!,
                          style: const TextStyle(
                              fontFamily: 'RussoOne', color: Colors.red)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _save(
      BuildContext context, WorkoutBuilderController controller) async {
    final workout = await controller.save();
    if (workout != null && context.mounted) Navigator.of(context).pop();
  }

  void _openExerciseForm(
    BuildContext context,
    WorkoutBuilderController ctrl, {
    Exercise? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFF6F3C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.black, width: 2),
      ),
      builder: (_) => _ExerciseFormSheet(
        initial: existing ?? ctrl.createBlankExercise(),
        onSave: (exercise) {
          if (existing != null) {
            ctrl.updateExercise(existing.id, exercise);
          } else {
            ctrl.addExercise(exercise);
          }
        },
      ),
    );
  }
}

// ── Exercise Tile ─────────────────────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    super.key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDuration = exercise.type == ExerciseType.duration;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E93AB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.drag_handle, color: Colors.black54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              exercise.name.isEmpty ? '(Unnamed)' : exercise.name,
              style: const TextStyle(
                fontFamily: 'RussoOne',
                fontWeight: FontWeight.bold,
                fontSize: 15,
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
          const SizedBox(width: 10),
          if (isDuration) ...[
            Container(
              width: 28,
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
          _ActionButton(
              label: 'Edit', color: const Color(0xFFEEFF5E), onTap: onEdit),
          const SizedBox(width: 2),
          _ActionButton(
              label: 'Delete', color: const Color(0xFFE53935), onTap: onDelete),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
              : const [BoxShadow(color: Colors.black, offset: Offset(0, 4))],
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

// ── Exercise Form Sheet ───────────────────────────────────────────────────────

class _ExerciseFormSheet extends StatefulWidget {
  const _ExerciseFormSheet({required this.initial, required this.onSave});
  final Exercise initial;
  final void Function(Exercise) onSave;

  @override
  State<_ExerciseFormSheet> createState() => _ExerciseFormSheetState();
}

class _ExerciseFormSheetState extends State<_ExerciseFormSheet> {
  late String _name;
  late ExerciseType _type;
  late int _sets;
  late int _reps;
  late int _durationSeconds;
  late int _restSeconds;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _name = widget.initial.name;
    _type = widget.initial.type;
    _sets = widget.initial.sets;
    _reps = widget.initial.reps;
    _durationSeconds = widget.initial.duration?.inSeconds ?? 30;
    _restSeconds = widget.initial.restTime.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Text(
            'Exercise Detail',
            style: TextStyle(
                fontFamily: 'RussoOne',
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          const SizedBox(height: 16),

          _StyledTextField(
            initialValue: _name,
            hint: 'Exercise Name',
            onChanged: (v) => setState(() {
              _name = v;
              _nameError = null;
            }),
          ),

          if (_nameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _nameError!,
                style: const TextStyle(
                  fontFamily: 'RussoOne',
                  color: const Color(0xFFE53935),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 12),

          Material(
            color: Colors.transparent,
            elevation: 4,
            shadowColor: Colors.black,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: SegmentedButton<ExerciseType>(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? const Color(0xFF347433)
                        : Colors.white),
                foregroundColor: MaterialStateProperty.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Colors.white
                        : Colors.black),
                side: MaterialStateProperty.all(
                    const BorderSide(color: Colors.black, width: 2)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
              ),
              segments: const [
                ButtonSegment(
                  value: ExerciseType.repetition,
                  label: Text('Repetition',
                      style: TextStyle(fontFamily: 'RussoOne', fontSize: 12)),
                ),
                ButtonSegment(
                  value: ExerciseType.duration,
                  label: Text('Duration',
                      style: TextStyle(fontFamily: 'RussoOne', fontSize: 12)),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
          ),
          const SizedBox(height: 12),

          _NumberField(
            label: 'Sets',
            value: _sets,
            min: 1,
            max: 20,
            onChanged: (v) => setState(() => _sets = v),
          ),

          if (_type == ExerciseType.repetition) ...[
            const SizedBox(height: 8),
            _NumberField(
              label: 'Repetition/set',
              value: _reps,
              min: 1,
              max: 100,
              onChanged: (v) => setState(() => _reps = v),
            ),
          ],

          if (_type == ExerciseType.duration) ...[
            const SizedBox(height: 8),
            _NumberField(
              label: 'Duration/set (second)',
              value: _durationSeconds,
              min: 5,
              max: 600,
              onChanged: (v) => setState(() => _durationSeconds = v),
            ),
          ],

          const SizedBox(height: 8),
          _NumberField(
            label: 'Rest (second)',
            value: _restSeconds,
            min: 0,
            max: 300,
            onChanged: (v) => setState(() => _restSeconds = v),
          ),
          const SizedBox(height: 20),

          AnimatedButton(
            onTap: _name.trim().isEmpty ? null : _submit,
            sound: WorkoutSound.save,
            builder: (isPressed) => Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _name.trim().isEmpty
                    ? const Color(0xFFCDC6C6)
                    : const Color(0xFFB22222),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: isPressed
                    ? []
                    : const [
                        BoxShadow(color: Colors.black, offset: Offset(0, 4))
                      ],
              ),
              child: const Center(
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    fontFamily: 'RussoOne',
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

  String? _validate() {
    if (_name.trim().isEmpty) return 'Nama exercise tidak boleh kosong';
    if (_sets < 1) return 'Sets minimal 1';
    if (_type == ExerciseType.repetition && _reps < 1) return 'Reps minimal 1';
    if (_type == ExerciseType.duration && _durationSeconds < 5) {
      return 'Durasi minimal 5 detik';
    }
    return null;
  }

  void _submit() {
    final error = _validate();
    if (error != null) {
      setState(() => _nameError = error);
      return;
    }
    widget.onSave(widget.initial.copyWith(
      name: _name.trim(),
      type: _type,
      sets: _sets,
      reps: _reps,
      duration: _type == ExerciseType.duration
          ? Duration(seconds: _durationSeconds)
          : null,
      restTime: Duration(seconds: _restSeconds),
    ));
    Navigator.of(context).pop();
  }
}

// ── Styled Text Field ─────────────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.initialValue,
    required this.hint,
    required this.onChanged,
  });

  final String initialValue;
  final String hint;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        style: const TextStyle(
            fontFamily: 'RussoOne', fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'RussoOne', fontSize: 16, color: Colors.black),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Number Stepper ────────────────────────────────────────────────────────────

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'RussoOne', fontWeight: FontWeight.w500)),
          ),
          AnimatedButton(
            onTap: value > min ? () => onChanged(value - 1) : null,
            builder: (isPressed) => _StepperBtn(
              icon: Icons.remove,
              isPressed: isPressed,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'RussoOne',
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          AnimatedButton(
            onTap: value < max ? () => onChanged(value + 1) : null,
            builder: (isPressed) => _StepperBtn(
              icon: Icons.add,
              isPressed: isPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.isPressed});
  final IconData icon;
  final bool isPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: isPressed
            ? []
            : const [BoxShadow(color: Colors.black, offset: Offset(0, 4))],
      ),
      child: Icon(icon, size: 16),
    );
  }
}
