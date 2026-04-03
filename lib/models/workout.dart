import 'exercise.dart';

class Workout {
  final String id;
  final String name;
  final String? description;
  final List<Exercise> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Workout({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    required this.createdAt,
    this.updatedAt,
  });

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<Exercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.sets);

  int get totalExercises => exercises.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    exercises: (json['exercises'] as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
  );
}
