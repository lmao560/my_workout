import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repository/repository.dart';
import '../services/id_services.dart';

/// Manages the user's [WorkoutPlan] (schedule).
///
/// One plan holds all [ScheduledWorkout] slots.
/// This controller loads/saves the active plan and exposes
/// helpers for today's schedules
class ScheduleController extends ChangeNotifier {
  ScheduleController({
    required WorkoutPlanRepository planRepository,
    required WorkoutRepository workoutRepository,
  })  : _planRepo = planRepository,
        _workoutRepo = workoutRepository;

  final WorkoutPlanRepository _planRepo;
  final WorkoutRepository _workoutRepo;

  WorkoutPlan? _plan;
  List<Workout> _allWorkouts = [];
  bool _isLoading = false;
  String? _error;

  WorkoutPlan? get plan => _plan;
  List<Workout> get allWorkouts => _allWorkouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Slots scheduled for today, with their [Workout] resolved.
  List<({ScheduledWorkout slot, Workout? workout})> get todaySlots {
    if (_plan == null) return [];
    return _plan!.todaySchedule.map((slot) {
      final workout = _allWorkouts.firstWhere(
            (w) => w.id == slot.workoutId,
        orElse: () => Workout(
          id: slot.workoutId,
          name: '[Deleted Workout]',
          exercises: [],
          createdAt: DateTime.now(),
        ),
      );
      return (slot: slot, workout: workout);
    }).toList();
  }

  // ── Load ─────────────────────────────────────────────────────────────────────

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allWorkouts = await _workoutRepo.getAll();
      final plans = await _planRepo.getAll();
      // Use first plan or create a default one
      _plan = plans.isNotEmpty
          ? plans.first
          : WorkoutPlan(
        id: IdService.generate(),
        name: 'My Schedule',
        schedule: [],
        createdAt: DateTime.now(),
      );
    } catch (e) {
      _error = 'Failed to load schedule: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Schedule management ───────────────────────────────────────────────────────

  Future<void> addScheduledWorkout({
    required String workoutId,
    required List<Weekday> days,
    String? note,
  }) async {
    if (_plan == null) return;

    final slot = ScheduledWorkout(
      id: IdService.generate(),
      workoutId: workoutId,
      days: days,
      note: note,
    );

    final updated = _plan!.copyWith(
      schedule: [..._plan!.schedule, slot],
    );

    await _persist(updated);
  }

  Future<void> updateScheduledWorkout(ScheduledWorkout updated) async {
    if (_plan == null) return;

    final newSchedule = _plan!.schedule
        .map((s) => s.id == updated.id ? updated : s)
        .toList();

    await _persist(_plan!.copyWith(schedule: newSchedule));
  }

  Future<void> removeScheduledWorkout(String slotId) async {
    if (_plan == null) return;

    final newSchedule =
    _plan!.schedule.where((s) => s.id != slotId).toList();

    await _persist(_plan!.copyWith(schedule: newSchedule));
  }

  Future<void> toggleSlotActive(String slotId) async {
    if (_plan == null) return;

    final slot = _plan!.schedule.firstWhere((s) => s.id == slotId);
    await updateScheduledWorkout(slot.copyWith(isActive: !slot.isActive));
  }

  // ── Internal ──────────────────────────────────────────────────────────────────

  Future<void> _persist(WorkoutPlan plan) async {
    try {
      await _planRepo.save(plan);
      _plan = plan;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save schedule: $e';
      notifyListeners();
    }
  }
}
