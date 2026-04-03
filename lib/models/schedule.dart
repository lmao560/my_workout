/// Days of the week — matches DateTime.weekday (1=Mon … 7=Sun).
enum Weekday {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const Weekday(this.value);
  final int value;

  String get label => name[0].toUpperCase() + name.substring(1);

  static Weekday fromValue(int value) =>
      Weekday.values.firstWhere((d) => d.value == value);
}

// ----------------------------------------------------------------------------

/// A single slot in the schedule: which days + which workout.
class ScheduledWorkout {
  final String id;
  final String workoutId; // FK → Workout.id
  final List<Weekday> days;
  final String? note; // e.g. "Morning session"
  final bool isActive;

  const ScheduledWorkout({
    required this.id,
    required this.workoutId,
    required this.days,
    this.note,
    this.isActive = true,
  });

  ScheduledWorkout copyWith({
    String? id,
    String? workoutId,
    List<Weekday>? days,
    String? note,
    bool? isActive,
  }) {
    return ScheduledWorkout(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      days: days ?? this.days,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Returns true if this schedule is active on today's weekday.
  bool isScheduledToday() {
    final today = Weekday.fromValue(DateTime.now().weekday);
    return isActive && days.contains(today);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'days': days.map((d) => d.value).toList(),
    'note': note,
    'isActive': isActive,
  };

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) =>
      ScheduledWorkout(
        id: json['id'] as String,
        workoutId: json['workoutId'] as String,
        days: (json['days'] as List)
            .map((v) => Weekday.fromValue(v as int))
            .toList(),
        note: json['note'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );
}

// ----------------------------------------------------------------------------

/// Top-level plan: a named collection of [ScheduledWorkout] slots.
/// Scalable to a full calendar later — just extend slots with date ranges.
class WorkoutPlan {
  final String id;
  final String name; // e.g. "Week 1 – Strength"
  final List<ScheduledWorkout> schedule;
  final DateTime createdAt;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.schedule,
    required this.createdAt,
  });

  WorkoutPlan copyWith({
    String? id,
    String? name,
    List<ScheduledWorkout>? schedule,
    DateTime? createdAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns all slots scheduled for today.
  List<ScheduledWorkout> get todaySchedule =>
      schedule.where((s) => s.isScheduledToday()).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'schedule': schedule.map((s) => s.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
    id: json['id'] as String,
    name: json['name'] as String,
    schedule: (json['schedule'] as List)
        .map((s) => ScheduledWorkout.fromJson(s as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
