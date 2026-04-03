import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repository/repository.dart';

class WorkoutListController extends ChangeNotifier {
  WorkoutListController({required WorkoutRepository repository})
      : _repository = repository;

  // ── Dependencies ──────────────────────────────────────────────────────────────

  final WorkoutRepository _repository;

  // ── State ─────────────────────────────────────────────────────────────────────

  List<Workout> _workouts = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────────

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get workoutNames => _workouts.map((w) => w.name).toList();

  // ── Actions ───────────────────────────────────────────────────────────────────

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workouts = await _repository.getAll();
    } catch (e) {
      _error = 'Failed to load workouts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(String workoutId) async {
    try {
      await _repository.delete(workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() => load();
}
