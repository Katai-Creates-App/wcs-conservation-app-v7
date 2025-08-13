import '../models/observation.dart';

abstract class DatabaseHelperInterface {
  Future<void> initialize();
  Future<int> insertObservation(Observation obs);
  Future<List<Observation>> getObservations();
  Future<int> updateObservation(Observation obs);
  Future<int> deleteObservation(int id);
} 