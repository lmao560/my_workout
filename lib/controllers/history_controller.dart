import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repository/repository.dart';

class HistoryController extends ChangeNotifier {
  HistoryController({required HistoryRepository repository})
      : _repository = repository;

  final HistoryRepository _repository;

  List<WorkoutHistory> _history = [];
  bool _isLoading = false;

  List<WorkoutHistory> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _history = await _repository.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await load();
  }
}
