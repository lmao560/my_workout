import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import '../models/schedule.dart';
import 'repository.dart';

// ── Workout Repository ────────────────────────────────────────────────────────

Map<String, dynamic> _toStringMap(Map map) {
  return map.map((key, value) {
    if (value is Map) return MapEntry(key.toString(), _toStringMap(value));
    if (value is List) return MapEntry(key.toString(), _toList(value));
    return MapEntry(key.toString(), value);
  });
}

List _toList(List list) {
  return list.map((item) {
    if (item is Map) return _toStringMap(item);
    if (item is List) return _toList(item);
    return item;
  }).toList();
}

class HiveWorkoutRepository implements WorkoutRepository {
  final Box _box = Hive.box('workouts');

  @override
  Future<List<Workout>> getAll() async {
    debugPrint('📦 Hive loaded: ${_box.length} workouts');
    try {
      final result = _box.values
          .map((v) => Workout.fromJson(_toStringMap(v as Map))) // ← ganti
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint('📦 Parsed: ${result.length} workouts');
      return result;
    } catch (e) {
      debugPrint('❌ GetAll error: $e');
      return [];
    }
  }

  @override
  Future<Workout?> getById(String id) async {
    final v = _box.get(id);
    if (v == null) return null;
    return Workout.fromJson(_toStringMap(v as Map));
  }

  @override
  Future<void> save(Workout workout) async {
    try {
      await _box.put(workout.id, workout.toJson());
      debugPrint('✅ Saved: ${workout.name} | Total: ${_box.length}');
    } catch (e) {
      debugPrint('❌ Save error: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}

// ── Workout Plan Repository ───────────────────────────────────────────────────

class HiveWorkoutPlanRepository implements WorkoutPlanRepository {
  final Box _box = Hive.box('plans');

  @override
  Future<List<WorkoutPlan>> getAll() async {
    return _box.values
        .map((v) => WorkoutPlan.fromJson(_toStringMap(v as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<WorkoutPlan?> getById(String id) async {
    final v = _box.get(id);
    if (v == null) return null;
    return WorkoutPlan.fromJson(_toStringMap(v as Map));
  }

  @override
  Future<void> save(WorkoutPlan plan) async {
    await _box.put(plan.id, plan.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}

// ── History Repository ────────────────────────────────────────────────────────

class HiveHistoryRepository implements HistoryRepository {
  final Box _box = Hive.box('history');

  @override
  Future<List<WorkoutHistory>> getAll() async {
    return _box.values
        .map((v) => WorkoutHistory.fromJson(_toStringMap(v as Map)))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  @override
  Future<void> save(WorkoutHistory history) async {
    await _box.put(history.id, history.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
