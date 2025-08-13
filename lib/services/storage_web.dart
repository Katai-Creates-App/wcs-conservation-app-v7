import '../models/observation.dart';
import 'observation_storage_service.dart';

class WebStorageService implements ObservationStorageService {
  static final List<Map<String, dynamic>> _observations = [];
  static int _nextId = 1;
  static bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    
    // For now, use in-memory storage for web
    // TODO: Implement shared_preferences when available
    _initialized = true;
  }

  @override
  Future<int> insert(Observation observation) async {
    try {
      final id = _nextId++;
      final map = observation.toMap();
      map['id'] = id;
      _observations.add(map);
      return id;
    } catch (e) {
      print('Web storage insert failed: $e');
      return -1;
    }
  }

  @override
  Future<List<Observation>> getAll() async {
    try {
      return _observations
          .map((map) => Observation.fromMap(map))
          .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      print('Web storage get all failed: $e');
      return [];
    }
  }

  @override
  Future<int> update(Observation observation) async {
    try {
      final index = _observations.indexWhere((map) => map['id'] == observation.id);
      if (index != -1) {
        _observations[index] = observation.toMap();
        return 1;
      }
      return 0;
    } catch (e) {
      print('Web storage update failed: $e');
      return -1;
    }
  }

  @override
  Future<int> delete(int id) async {
    try {
      final index = _observations.indexWhere((map) => map['id'] == id);
      if (index != -1) {
        _observations.removeAt(index);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Web storage delete failed: $e');
      return -1;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      _observations.clear();
      _nextId = 1;
    } catch (e) {
      print('Web storage clear all failed: $e');
    }
  }
} 