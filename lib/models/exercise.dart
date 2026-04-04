// ============================================================================
// models/exercise.dart
// ============================================================================

enum ExerciseType { repetition, duration }

class Exercise {
  final String id;
  final String name;
  final ExerciseType type;
  final int sets;
  final int reps;
  final Duration? duration; // only for ExerciseType.duration
  final Duration restTime;

  const Exercise({
    required this.id,
    required this.name,
    required this.type,
    required this.sets,
    this.reps = 10,
    this.duration,
    this.restTime = const Duration(seconds: 30),
  });

  Exercise copyWith({
    String? id,
    String? name,
    ExerciseType? type,
    int? sets,
    int? reps,
    Duration? duration,
    Duration? restTime,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      restTime: restTime ?? this.restTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'sets': sets,
    'reps': reps,
    'durationSeconds': duration?.inSeconds,
    'restTimeSeconds': restTime.inSeconds,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String,
    name: json['name'] as String,
    type: ExerciseType.values.byName(json['type'] as String),
    sets: json['sets'] as int,
    reps: json['reps'] as int ?? 10,
    duration: json['durationSeconds'] != null
        ? Duration(seconds: json['durationSeconds'] as int)
        : null,
    restTime: Duration(seconds: json['restTimeSeconds'] as int? ?? 30),
  );
}
