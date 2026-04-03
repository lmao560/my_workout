import 'exercise.dart';

enum ExercisePhase { idle, active, resting, waitingFinish,completed }

class ExerciseProgress {
  final Exercise exercise;
  final int currentSet;
  final ExercisePhase phase;
  final Duration? remainingTime;

  const ExerciseProgress({
    required this.exercise,
    required this.currentSet,
    required this.phase,
    this.remainingTime,
  });

  bool get isLastSet => currentSet >= exercise.sets;
  int get completedSets => currentSet - 1;
  int get remainingSets => exercise.sets - (currentSet - 1);

  ExerciseProgress copyWith({
    Exercise? exercise,
    int? currentSet,
    ExercisePhase? phase,
    Duration? remainingTime,
  }) {
    return ExerciseProgress(
      exercise: exercise ?? this.exercise,
      currentSet: currentSet ?? this.currentSet,
      phase: phase ?? this.phase,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}

// ----------------------------------------------------------------------------

enum SessionStatus { idle, running, completed }

class WorkoutSession {
  final String workoutId;
  final SessionStatus status;
  final int currentExerciseIndex;
  final ExerciseProgress? currentProgress;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const WorkoutSession({
    required this.workoutId,
    this.status = SessionStatus.idle,
    this.currentExerciseIndex = 0,
    this.currentProgress,
    this.startedAt,
    this.completedAt,
  });

  bool get isRunning => status == SessionStatus.running;
  bool get isCompleted => status == SessionStatus.completed;

  /// Elapsed duration since session started.
  Duration get elapsed =>
      startedAt != null ? DateTime.now().difference(startedAt!) : Duration.zero;

  WorkoutSession copyWith({
    String? workoutId,
    SessionStatus? status,
    int? currentExerciseIndex,
    ExerciseProgress? currentProgress,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return WorkoutSession(
      workoutId: workoutId ?? this.workoutId,
      status: status ?? this.status,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentProgress: currentProgress ?? this.currentProgress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
