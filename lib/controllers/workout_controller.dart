import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/timer_service.dart';
import '../repository/repository.dart';
import '../services/id_services.dart';
import '../services/sound_service.dart';
import '../models/history.dart';

/// Core workout session controller.
/// Logic is identical to v1 — unchanged by the new builder/schedule features.
class WorkoutController extends ChangeNotifier {
  WorkoutController({
    TimerService? timerService,
    HistoryRepository? historyRepository,
    SoundService? soundService,
  })  : _timer = timerService ?? TimerService(),
        _historyRepo = historyRepository,
        _soundService = soundService ?? SoundService();

  final TimerService _timer;
  final HistoryRepository? _historyRepo;
  final SoundService _soundService;

  final Set<int> _completedExercises = {};
  final Map<int, DateTime> _exerciseStartTimes = {};

  Set<int> get completedExercises => Set.unmodifiable(_completedExercises);

  bool get allExercisesCompleted =>
      _workout != null &&
          _completedExercises.length >= _workout!.exercises.length;

// Mulai exercise tertentu by index
  void startExercise(int index) {
    if (_workout == null) return;
    _timer.cancel();
    _exerciseStartTimes[index] = DateTime.now();

    _session = WorkoutSession(
      workoutId: _workout!.id,
      status: SessionStatus.running,
      currentExerciseIndex: index,
      startedAt: _session?.startedAt ?? DateTime.now(),
    );

    _beginExercise(index);
  }

// Cancel exercise yang sedang berjalan
  void cancelExercise() {
    _timer.cancel();
    _session = _session?.copyWith(
      status: SessionStatus.idle,
      currentProgress: null,
    );
    notifyListeners();
  }

// Override _completeSession agar tidak auto-complete,
// tapi mark exercise sebagai selesai
  void _completeCurrentExercise() {
    _soundService.play(WorkoutSound.exerciseDone);
    if (_session == null) return;
    _completedExercises.add(_session!.currentExerciseIndex);
    _timer.cancel();
    _session = _session!.copyWith(
      status: SessionStatus.idle,
      currentProgress:
      currentProgress?.copyWith(phase: ExercisePhase.completed),
    );
    notifyListeners();
  }

// Panggil ini dari tombol COMPLETE
  void completeSession() {
    _soundService.play(WorkoutSound.complete);
    if (!allExercisesCompleted) return;

    final endTime = DateTime.now();
    final startTime = _session?.startedAt ?? endTime;

    // Build exercise results
    final results = _workout!.exercises.asMap().entries.map((entry) {
      final i = entry.key;
      final ex = entry.value;
      final exStart = _exerciseStartTimes[i] ?? startTime;
      return ExerciseResult(
        exerciseId: ex.id,
        exerciseName: ex.name,
        type: ex.type,
        sets: ex.sets,
        reps: ex.reps,
        duration: ex.duration,
        totalTime: endTime.difference(exStart),
      );
    }).toList();

    final history = WorkoutHistory(
      id: IdService.generate(),
      workoutId: _workout!.id,
      workoutName: _workout!.name,
      completedAt: endTime,
      totalDuration: endTime.difference(startTime),
      exercises: results,
    );

    _historyRepo?.save(history);

    _session = _session?.copyWith(
      status: SessionStatus.completed,
      completedAt: endTime,
    );
    notifyListeners();
  }

// Reset saat load workout baru
  @override
  void loadWorkout(Workout workout) {
    _timer.cancel();
    _completedExercises.clear();
    _exerciseStartTimes.clear();
    _workout = workout;
    _session = WorkoutSession(workoutId: workout.id);
    notifyListeners();
  }

  Workout? _workout;
  WorkoutSession? _session;

  Workout? get workout => _workout;
  WorkoutSession? get session => _session;

  bool get isRunning => _session?.isRunning ?? false;
  bool get isCompleted => _session?.isCompleted ?? false;

  ExerciseProgress? get currentProgress => _session?.currentProgress;
  Exercise? get currentExercise => currentProgress?.exercise;
  ExercisePhase get currentPhase =>
      currentProgress?.phase ?? ExercisePhase.idle;

  // ── Session lifecycle ────────────────────────────────────────────────────────
  void startSession() {
    assert(_workout != null, 'Call loadWorkout() before startSession()');
    if (_workout!.exercises.isEmpty) return;

    _session = WorkoutSession(
      workoutId: _workout!.id,
      status: SessionStatus.running,
      currentExerciseIndex: 0,
      startedAt: DateTime.now(),
    );

    _beginExercise(0);
  }

  void stopSession() {
    _timer.cancel();
    _session = _session?.copyWith(status: SessionStatus.idle);
    notifyListeners();
  }

  // ── User actions ─────────────────────────────────────────────────────────────

  void onNextSet() {
    final progress = currentProgress;
    if (progress == null) return;
    if (progress.phase != ExercisePhase.active) return;
    if (progress.exercise.type != ExerciseType.repetition) return;
    _finishActivePhase();
  }

  void skipRest() {
    final progress = currentProgress;
    if (progress == null) return;
    if (progress.phase != ExercisePhase.resting) return;
    //_soundService.stopLoop();
    _timer.cancel();
    _finishRest();
  }

  // ── Internal flow ────────────────────────────────────────────────────────────

  void _beginExercise(int index) {
    final exercise = _workout!.exercises[index];

    _session = _session!.copyWith(
      currentExerciseIndex: index,
      currentProgress: ExerciseProgress(
        exercise: exercise,
        currentSet: 1,
        phase: ExercisePhase.active,
      ),
    );
    notifyListeners();

    if (exercise.type == ExerciseType.duration) {
      _startDurationTimer(exercise.duration!);
    }
  }

  void _startDurationTimer(Duration duration) {
    _timer.start(
      duration: duration,
      onTick: (remaining) {
        if (remaining.inSeconds <= 3 && remaining.inSeconds > 0) {
          _soundService.play(WorkoutSound.countdown);
        }
        _session = _session!.copyWith(
          currentProgress: currentProgress!.copyWith(remainingTime: remaining),
        );
        notifyListeners();
      },
      onDone: _finishActivePhase,
    );
  }

  void _finishActivePhase() {
    final progress = currentProgress!;
    _beginRest(progress);
  }

  void _beginRest(ExerciseProgress progress) {
    _soundService.playWithTimeout(WorkoutSound.restStart, seconds: 1);
    _session = _session!.copyWith(
      currentProgress: progress.copyWith(
        phase: ExercisePhase.resting,
        remainingTime: progress.exercise.restTime,
      ),
    );
    notifyListeners();

    _timer.start(
      duration: progress.exercise.restTime,
      onTick: (remaining) {
        if (remaining.inSeconds <= 3 && remaining.inSeconds > 0) {
          _soundService.play(WorkoutSound.countdown);
        }
        _session = _session!.copyWith(
          currentProgress: currentProgress!.copyWith(remainingTime: remaining),
        );
        notifyListeners();
      },
      onDone: _finishRest,
    );
  }

  bool get soundEnabled => _soundService.enabled;

  void toggleSound() {
    _soundService.toggleSound();
    notifyListeners();
  }

  void _finishRest() {
    //_soundService.stopLoop();
    _soundService.play(WorkoutSound.restEnd);
    final progress = currentProgress!;

    if (progress.isLastSet) {
      // Rest selesai setelah set terakhir → tunggu user tekan FINISH
      _session = _session!.copyWith(
        currentProgress: progress.copyWith(
          phase: ExercisePhase.waitingFinish,
          remainingTime: Duration.zero,
        ),
      );
      notifyListeners();
    } else {
      // Masih ada set → lanjut active
      final exercise = progress.exercise;
      _session = _session!.copyWith(
        currentProgress: ExerciseProgress(
          exercise: exercise,
          currentSet: progress.currentSet + 1,
          phase: ExercisePhase.active,
        ),
      );
      notifyListeners();

      if (exercise.type == ExerciseType.duration) {
        _startDurationTimer(exercise.duration!);
      }
    }
  }

  void finishExercise() {
    if (currentProgress?.phase != ExercisePhase.waitingFinish) return;
    _completeCurrentExercise();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }
}
