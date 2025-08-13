import 'package:flutter/material.dart';
import '../models/observation.dart';
import '../services/observation_storage_service.dart';

class ObservationProvider extends ChangeNotifier {
  List<Observation> _observations = [];
  bool _isLoading = false;
  bool _usingFallback = false;
  String? _errorMessage;

  List<Observation> get observations => _observations;
  bool get isLoading => _isLoading;
  bool get usingFallback => _usingFallback;
  String? get errorMessage => _errorMessage;

  ObservationProvider() {
    loadObservations();
  }

  Future<void> loadObservations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await ObservationStorage().initialize();
      _observations = await ObservationStorage().getAll();
      _usingFallback = false;
      print('Loaded ${_observations.length} observations');
    } catch (e) {
      print('Failed to load observations: $e');
      _observations = [];
      _usingFallback = true;
      _errorMessage = 'Failed to load observations. Using temporary storage.';
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addObservation(Observation obs) async {
    try {
      final id = await ObservationStorage().insert(obs);
      if (id > 0) {
        await loadObservations();
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add observation: $e');
      _errorMessage = 'Failed to add observation.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateObservation(Observation obs) async {
    try {
      final result = await ObservationStorage().update(obs);
      if (result > 0) {
        await loadObservations();
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update observation: $e');
      _errorMessage = 'Failed to update observation.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteObservation(int id) async {
    try {
      final result = await ObservationStorage().delete(id);
      if (result > 0) {
        await loadObservations();
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete observation: $e');
      _errorMessage = 'Failed to delete observation.';
      notifyListeners();
      return false;
    }
  }

  Future<void> clearAllObservations() async {
    try {
      await ObservationStorage().clearAll();
      await loadObservations();
    } catch (e) {
      print('Failed to clear observations: $e');
      _errorMessage = 'Failed to clear observations.';
      notifyListeners();
    }
  }

  Observation? getById(int id) {
    for (final obs in _observations) {
      if (obs.id == id) return obs;
    }
    return null;
  }

  List<Observation> getBySpeciesType(SpeciesType type) {
    return _observations.where((obs) => obs.speciesType == type).toList();
  }

  List<Observation> getByConservationStatus(ConservationStatus status) {
    return _observations.where((obs) => obs.conservationStatus == status).toList();
  }

  List<Observation> searchObservations(String query) {
    if (query.isEmpty) return _observations;
    return _observations.where((obs) => 
      obs.speciesName.toLowerCase().contains(query.toLowerCase()) ||
      obs.description?.toLowerCase().contains(query.toLowerCase()) == true
    ).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 