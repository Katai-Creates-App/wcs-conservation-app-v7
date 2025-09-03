import 'package:flutter/foundation.dart';
import '../models/observation.dart';

// Platform-specific imports
import 'storage_mobile.dart';
import 'storage_web.dart';

abstract class ObservationStorageService {
  Future<void> initialize();
  Future<int> insert(Observation observation);
  Future<List<Observation>> getAll();
  Future<int> update(Observation observation);
  Future<int> delete(int id);
  Future<void> clearAll();
}

class ObservationStorage implements ObservationStorageService {
  static final ObservationStorage _instance = ObservationStorage._internal();
  factory ObservationStorage() => _instance;
  ObservationStorage._internal();

  late final ObservationStorageService _impl;
  bool _initialized = false;

  ObservationStorageService _createStorageService() {
    return kIsWeb ? WebStorageService() : MobileStorageService();
  }

  @override
  Future<void> initialize() async {
    print('ObservationStorage.initialize: Starting initialization');
    if (_initialized) {
      print('ObservationStorage.initialize: Already initialized, returning early');
      return;
    }
    
    try {
      print('ObservationStorage.initialize: Creating platform-specific storage service');
      _impl = _createStorageService();
      print('ObservationStorage.initialize: Platform service created: ${_impl.runtimeType}');
      
      print('ObservationStorage.initialize: Calling platform service initialize()');
      await _impl.initialize();
      _initialized = true;
      print('ObservationStorage.initialize: Storage initialized successfully for ${kIsWeb ? 'web' : 'mobile'}');
    } catch (e, stackTrace) {
      print('ObservationStorage.initialize: Storage initialization failed: $e');
      print('ObservationStorage.initialize: Stack trace: $stackTrace');
      print('ObservationStorage.initialize: Using in-memory fallback');
      _impl = InMemoryStorageService();
      await _impl.initialize();
      _initialized = true;
      print('ObservationStorage.initialize: In-memory fallback initialized successfully');
    }
  }

  @override
  Future<int> insert(Observation observation) async {
    try {
      final id = await _impl.insert(observation);
      print('Observation inserted with ID: $id');
      return id;
    } catch (e) {
      print('Insert failed: $e');
      return -1;
    }
  }

  @override
  Future<List<Observation>> getAll() async {
    try {
      final observations = await _impl.getAll();
      print('Retrieved ${observations.length} observations');
      return observations;
    } catch (e) {
      print('Get all failed: $e');
      return [];
    }
  }

  @override
  Future<int> update(Observation observation) async {
    try {
      final result = await _impl.update(observation);
      print('Observation updated: $result rows affected');
      return result;
    } catch (e) {
      print('Update failed: $e');
      return -1;
    }
  }

  @override
  Future<int> delete(int id) async {
    try {
      final result = await _impl.delete(id);
      print('Observation deleted: $result rows affected');
      return result;
    } catch (e) {
      print('Delete failed: $e');
      return -1;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _impl.clearAll();
      print('All observations cleared');
    } catch (e) {
      print('Clear all failed: $e');
    }
  }
}

// In-memory fallback implementation
class InMemoryStorageService implements ObservationStorageService {
  static final List<Map<String, dynamic>> _observations = [];
  static int _nextId = 1;

  @override
  Future<void> initialize() async {
    print('InMemoryStorageService.initialize: Starting in-memory storage initialization');
    // Load sample data for demonstration
    if (_observations.isEmpty) {
      print('InMemoryStorageService.initialize: Loading sample data');
      await _loadSampleData();
      print('InMemoryStorageService.initialize: Sample data loaded successfully');
    } else {
      print('InMemoryStorageService.initialize: Sample data already loaded, skipping');
    }
    print('InMemoryStorageService.initialize: In-memory storage initialization completed');
  }

  Future<void> _loadSampleData() async {
    print('InMemoryStorageService._loadSampleData: Creating sample observations');
    final sampleObservations = [
      Observation(
        speciesName: 'Red Maple',
        speciesType: SpeciesType.plant,
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        quantity: 15,
        description: 'Healthy red maple trees in the northern forest area.',
        conservationStatus: ConservationStatus.healthy,
        habitatType: HabitatType.forest,
      ),
      Observation(
        speciesName: 'Bald Eagle',
        speciesType: SpeciesType.animal,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        quantity: 3,
        description: 'Nesting pair with one juvenile observed near the lake.',
        conservationStatus: ConservationStatus.threatened,
        habitatType: HabitatType.wetland,
      ),
      Observation(
        speciesName: 'Blue Spruce',
        speciesType: SpeciesType.plant,
        dateTime: DateTime.now(),
        quantity: 8,
        description: 'Mature blue spruce trees in the mountain region.',
        conservationStatus: ConservationStatus.healthy,
        habitatType: HabitatType.forest,
      ),
    ];

    print('InMemoryStorageService._loadSampleData: Inserting ${sampleObservations.length} sample observations');
    for (final obs in sampleObservations) {
      final id = await insert(obs);
      print('InMemoryStorageService._loadSampleData: Inserted sample observation with ID: $id');
    }
    print('InMemoryStorageService._loadSampleData: Sample data loading completed');
  }

  @override
  Future<int> insert(Observation observation) async {
    final id = _nextId++;
    final map = observation.toMap();
    map['id'] = id;
    _observations.add(map);
    return id;
  }

  @override
  Future<List<Observation>> getAll() async {
    return _observations
        .map((map) => Observation.fromMap(map))
        .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  @override
  Future<int> update(Observation observation) async {
    final index = _observations.indexWhere((map) => map['id'] == observation.id);
    if (index != -1) {
      _observations[index] = observation.toMap();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> delete(int id) async {
    final index = _observations.indexWhere((map) => map['id'] == id);
    if (index != -1) {
      _observations.removeAt(index);
      return 1;
    }
    return 0;
  }

  @override
  Future<void> clearAll() async {
    _observations.clear();
    _nextId = 1;
  }
} 