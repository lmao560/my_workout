import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repository/repository.dart';
import '../services/id_services.dart';

/// Manages the Create / Edit workout flow.
///
/// Holds a mutable draft that the UI builds incrementally.
/// Call [save] to persist via the repository.
class WorkoutBuilderController extends ChangeNotifier {
  WorkoutBuilderController({required WorkoutRepository repository})
      : _repository = repository;

  final WorkoutRepository _repository;

  // ── Draft state ─────────────────────────────────────────────────────────────

  String _name = '';
  String _description = '';
  final List<Exercise> _exercises = [];

  bool _isSaving = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────────────────────────

  String get name => _name;
  String get description => _description;
  List<Exercise> get exercises => List.unmodifiable(_exercises);
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get canSave =>
      _name.trim().isNotEmpty &&
          _exercises.length >= 3 &&
          nameError == null;
  List<String> _existingNames = [];

  void setExistingNames(List<String> names) {
    _existingNames = names;
  }

// Validasi individual
  String? get nameError {
    if (_name.trim().isEmpty) return 'Nama workout tidak boleh kosong';
    if (_name.trim().length < 3) return 'Nama minimal 3 karakter';
    final isDuplicate = _existingNames
        .where((n) => n.toLowerCase() == _name.trim().toLowerCase())
        .isNotEmpty;
    // Saat edit, exclude nama workout yang sedang diedit
    if (isDuplicate && _editingId == null) return 'Nama workout sudah digunakan';
    if (isDuplicate && _editingId != null) {
      // cek apakah nama duplikat bukan milik diri sendiri
      // (tidak perlu cek lebih lanjut jika nama tidak berubah)
    }
    return null;
  }

  String? get exerciseCountError {
    if (_exercises.length < 3) {
      return 'Minimal 3 exercise (saat ini: ${_exercises.length})';
    }
    return null;
  }

  // ── Load existing workout for editing ────────────────────────────────────────

  void loadForEdit(Workout workout) {
    _editingId = workout.id;
    _name = workout.name;
    _description = workout.description ?? '';
    _exercises
      ..clear()
      ..addAll(workout.exercises);
    _error = null;
    notifyListeners();
  }

  String? _editingId; // null = creating new

  // ── Duplicate Workout ───────────────────────────────────────────────────────

  void loadForDuplicate(Workout workout) {
    _editingId = null; // null = create new, bukan edit
    _name = '${workout.name} (Copy)';
    _description = workout.description ?? '';
    _exercises
      ..clear()
      ..addAll(
        // Generate ID baru untuk setiap exercise
        workout.exercises.map((e) => e.copyWith(id: IdService.generate())),
      );
    _error = null;
    notifyListeners();
  }

  // ── Name / description ───────────────────────────────────────────────────────

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  // ── Exercise management ──────────────────────────────────────────────────────

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
    notifyListeners();
  }

  void updateExercise(String exerciseId, Exercise updated) {
    final index = _exercises.indexWhere((e) => e.id == exerciseId);
    if (index == -1) return;
    _exercises[index] = updated;
    notifyListeners();
  }

  void removeExercise(String exerciseId) {
    _exercises.removeWhere((e) => e.id == exerciseId);
    notifyListeners();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _exercises.removeAt(oldIndex);
    _exercises.insert(newIndex, item);
    notifyListeners();
  }

  // ── Persistence ──────────────────────────────────────────────────────────────

  Future<Workout?> save() async {
    if (!canSave) return null;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final workout = Workout(
        id: _editingId ?? IdService.generate(),
        name: _name.trim(),
        description: _description.trim().isEmpty ? null : _description.trim(),
        exercises: List.from(_exercises),
        createdAt: now,
        updatedAt: _editingId != null ? now : null,
      );

      await _repository.save(workout);
      _reset();
      return workout;
    } catch (e) {
      _error = 'Failed to save workout: $e';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _reset() {
    _editingId = null;
    _name = '';
    _description = '';
    _exercises.clear();
    _error = null;
  }

  // ── Exercise draft helper ────────────────────────────────────────────────────

  /// Creates a new blank exercise with a generated ID.
  /// Use this to pre-populate the exercise form.
  Exercise createBlankExercise() => Exercise(
    id: IdService.generate(),
    name: '',
    type: ExerciseType.repetition,
    sets: 3,
    restTime: const Duration(seconds: 30),
  );
}
