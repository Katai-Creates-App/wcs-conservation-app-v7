import '../models/observation.dart';

// Conditional imports for platform-specific database implementations
import 'database_helper_interface.dart';
import 'database_helper_mobile.dart' if (dart.library.html) 'database_helper_web.dart';

class DBHelper implements DatabaseHelperInterface {
  static final DBHelper instance = DBHelper._init();
  late final DatabaseHelperInterface _impl;

  DBHelper._init() {
    _impl = DatabaseHelperImpl();
  }

  @override
  Future<void> initialize() async {
    await _impl.initialize();
  }

  @override
  Future<int> insertObservation(Observation obs) async {
    try {
      return await _impl.insertObservation(obs);
    } catch (e) {
      print('Error inserting observation: $e');
      return -1;
    }
  }

  @override
  Future<List<Observation>> getObservations() async {
    try {
      return await _impl.getObservations();
    } catch (e) {
      print('Error getting observations: $e');
      return [];
    }
  }

  @override
  Future<int> updateObservation(Observation obs) async {
    try {
      return await _impl.updateObservation(obs);
    } catch (e) {
      print('Error updating observation: $e');
      return -1;
    }
  }

  @override
  Future<int> deleteObservation(int id) async {
    try {
      return await _impl.deleteObservation(id);
    } catch (e) {
      print('Error deleting observation: $e');
      return -1;
    }
  }
} 