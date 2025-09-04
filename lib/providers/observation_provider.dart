import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    print('ObservationProvider: Constructor called');
    loadObservations();
  }

  Future<void> loadObservations() async {
    print('ObservationProvider.loadObservations: Starting to load observations');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print('ObservationProvider.loadObservations: Initializing ObservationStorage');
      await ObservationStorage().initialize();
      print('ObservationProvider.loadObservations: ObservationStorage initialized, getting all observations');
      _observations = await ObservationStorage().getAll();
      _usingFallback = false;
      print('ObservationProvider.loadObservations: Loaded ${_observations.length} observations successfully');
    } catch (e, stackTrace) {
      print('ObservationProvider.loadObservations: ERROR loading observations: $e');
      print('ObservationProvider.loadObservations: Stack trace: $stackTrace');
      _observations = [];
      _usingFallback = true;
      _errorMessage = 'Failed to load observations. Using temporary storage.';
    }
    
    _isLoading = false;
    print('ObservationProvider.loadObservations: Setting isLoading to false and notifying listeners');
    notifyListeners();
    print('ObservationProvider.loadObservations: Completed');
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

  Future<void> syncToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final List<Observation> localObservations = await ObservationStorage().getAll();
      final CollectionReference collection = FirebaseFirestore.instance.collection('observations');

      for (var obs in localObservations) {
        if (obs.isSynced) {
          continue;
        }
        await collection.add({
          'speciesName': obs.speciesName,
          'speciesType': obs.speciesType.index,
          'location': obs.location,
          'date': obs.dateTime.toIso8601String(),
          'quantity': obs.quantity,
          'description': obs.description,
          'photoPath': obs.photoPath,
          'conservationStatus': obs.conservationStatus.index,
          'habitatType': obs.habitatType.index,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('✅ Uploaded: ' + obs.speciesName);

        // Immediately mark as synced locally before the next upload
        final updatedObs = obs.copyWith(isSynced: true);
        await ObservationStorage().update(updatedObs);
      }
      await loadObservations();
      print('✅ Successfully synchronized ' + localObservations.length.toString() + ' observations to Firestore');
    } on FirebaseException catch (e) {
      print('❌ Firestore sync failed: ' + e.toString());
    } catch (e) {
      print('❌ Unknown error: ' + e.toString());
    }
  }
} 