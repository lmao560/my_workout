import '../models/models.dart';

// ============================================================================
// Abstract interfaces — swap implementation (memory / Hive / SQLite / API)
// without touching any controller or UI code.
// ============================================================================

abstract class WorkoutRepository {
  Future<List<Workout>> getAll();
  Future<Workout?> getById(String id);
  Future<void> save(Workout workout);
  Future<void> delete(String id);
}

abstract class WorkoutPlanRepository {
  Future<List<WorkoutPlan>> getAll();
  Future<WorkoutPlan?> getById(String id);
  Future<void> save(WorkoutPlan plan);
  Future<void> delete(String id);
}

abstract class HistoryRepository {
  Future<List<WorkoutHistory>> getAll();
  Future<void> save(WorkoutHistory history);
  Future<void> delete(String id);
}
