import 'exercise.dart';

class ExerciseResult {
  final String exerciseId;
  final String exerciseName;
  final ExerciseType type;
  final int sets;
  final int reps;
  final Duration? duration;
  final Duration totalTime;

  const ExerciseResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.sets,
    required this.reps,
    this.duration,
    required this.totalTime,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'type': type.name,
    'sets': sets,
    'reps': reps,
    'durationSeconds': duration?.inSeconds,
    'totalTimeSeconds': totalTime.inSeconds,
  };

  factory ExerciseResult.fromJson(Map<String, dynamic> json) => ExerciseResult(
    exerciseId: json['exerciseId'] as String,
    exerciseName: json['exerciseName'] as String,
    type: ExerciseType.values.byName(json['type'] as String),
    sets: json['sets'] as int,
    reps: json['reps'] as int? ?? 0,
    duration: json['durationSeconds'] != null
        ? Duration(seconds: json['durationSeconds'] as int)
        : null,
    totalTime: Duration(seconds: json['totalTimeSeconds'] as int),
  );
}

class WorkoutHistory {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime completedAt;
  final Duration totalDuration;
  final List<ExerciseResult> exercises;

  const WorkoutHistory({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.completedAt,
    required this.totalDuration,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'workoutName': workoutName,
    'completedAt': completedAt.toIso8601String(),
    'totalDurationSeconds': totalDuration.inSeconds,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) => WorkoutHistory(
    id: json['id'] as String,
    workoutId: json['workoutId'] as String,
    workoutName: json['workoutName'] as String,
    completedAt: DateTime.parse(json['completedAt'] as String),
    totalDuration:
    Duration(seconds: json['totalDurationSeconds'] as int),
    exercises: (json['exercises'] as List)
        .map((e) => ExerciseResult.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
