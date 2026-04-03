import '../models/models.dart';
import 'repository.dart';

// ============================================================================
// In-memory implementation — data lives only for the app session.
// Replace this class with HiveWorkoutRepository or SqliteWorkoutRepository
// without changing any controller code.
// ============================================================================

class InMemoryWorkoutRepository implements WorkoutRepository {
  final Map<String, Workout> _store = {};

  @override
  Future<List<Workout>> getAll() async =>
      _store.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<Workout?> getById(String id) async => _store[id];

  @override
  Future<void> save(Workout workout) async => _store[workout.id] = workout;

  @override
  Future<void> delete(String id) async => _store.remove(id);
}

// ----------------------------------------------------------------------------

class InMemoryWorkoutPlanRepository implements WorkoutPlanRepository {
  final Map<String, WorkoutPlan> _store = {};

  @override
  Future<List<WorkoutPlan>> getAll() async =>
      _store.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<WorkoutPlan?> getById(String id) async => _store[id];

  @override
  Future<void> save(WorkoutPlan plan) async => _store[plan.id] = plan;

  @override
  Future<void> delete(String id) async => _store.remove(id);
}

class InMemoryHistoryRepository implements HistoryRepository {
  final List<WorkoutHistory> _store = [];

  @override
  Future<List<WorkoutHistory>> getAll() async =>
      _store.reversed.toList(); // terbaru di atas

  @override
  Future<void> save(WorkoutHistory history) async => _store.add(history);

  @override
  Future<void> delete(String id) async =>
      _store.removeWhere((h) => h.id == id);
}

// ============================================================================
// FUTURE: Hive implementation skeleton
// ============================================================================
//
// class HiveWorkoutRepository implements WorkoutRepository {
//   final Box<Map> _box = Hive.box('workouts');
//
//   @override
//   Future<List<Workout>> getAll() async =>
//       _box.values.map((v) => Workout.fromJson(Map<String,dynamic>.from(v))).toList();
//
//   @override
//   Future<void> save(Workout workout) async =>
//       _box.put(workout.id, workout.toJson());
//
//   @override
//   Future<void> delete(String id) async => _box.delete(id);
//
//   @override
//   Future<Workout?> getById(String id) async {
//     final v = _box.get(id);
//     return v != null ? Workout.fromJson(Map<String,dynamic>.from(v)) : null;
//   }
// }
