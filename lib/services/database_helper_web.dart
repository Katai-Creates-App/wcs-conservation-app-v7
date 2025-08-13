import '../models/observation.dart';
import 'database_helper_interface.dart';

class DatabaseHelperImpl implements DatabaseHelperInterface {
  static final List<Map<String, dynamic>> _observations = [];
  static int _nextId = 1;
  static bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  @override
  Future<int> insertObservation(Observation obs) async {
    final id = _nextId++;
    final map = obs.toMap();
    map['id'] = id;
    _observations.add(map);
    return id;
  }

  @override
  Future<List<Observation>> getObservations() async {
    return _observations
        .map((map) => Observation.fromMap(map))
        .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  @override
  Future<int> updateObservation(Observation obs) async {
    final index = _observations.indexWhere((map) => map['id'] == obs.id);
    if (index != -1) {
      _observations[index] = obs.toMap();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteObservation(int id) async {
    final index = _observations.indexWhere((map) => map['id'] == id);
    if (index != -1) {
      _observations.removeAt(index);
      return 1;
    }
    return 0;
  }
} 