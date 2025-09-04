enum SpeciesType { plant, animal }
enum ConservationStatus { healthy, threatened, endangered, critical }
enum HabitatType { forest, wetland, grassland, desert, marine, other }

class Observation {
  int? id;
  String speciesName;
  SpeciesType speciesType;
  String? location;
  DateTime dateTime;
  int quantity;
  String? description;
  String? photoPath;
  final String? audioPath;
  ConservationStatus conservationStatus;
  HabitatType habitatType;

  Observation({
    this.id,
    required this.speciesName,
    required this.speciesType,
    this.location,
    required this.dateTime,
    required this.quantity,
    this.description,
    this.photoPath,
    this.audioPath,
    required this.conservationStatus,
    required this.habitatType,
  });

  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      id: map['id'],
      speciesName: map['species_name'],
      speciesType: SpeciesType.values[map['species_type']],
      location: map['location'],
      dateTime: DateTime.parse(map['date']),
      quantity: map['quantity'],
      description: map['description'],
      photoPath: map['photo'],
      audioPath: map['audio_path'],
      conservationStatus: ConservationStatus.values[map['conservation_status']],
      habitatType: HabitatType.values[map['habitat_type']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species_name': speciesName,
      'species_type': speciesType.index,
      'location': location,
      'date': dateTime.toIso8601String(),
      'quantity': quantity,
      'description': description,
      'photo': photoPath,
      'audio_path': audioPath,
      'conservation_status': conservationStatus.index,
      'habitat_type': habitatType.index,
    };
  }

  Observation copyWith({
    int? id,
    String? speciesName,
    SpeciesType? speciesType,
    String? location,
    DateTime? dateTime,
    int? quantity,
    String? description,
    String? photoPath,
    String? audioPath,
    ConservationStatus? conservationStatus,
    HabitatType? habitatType,
  }) {
    return Observation(
      id: id ?? this.id,
      speciesName: speciesName ?? this.speciesName,
      speciesType: speciesType ?? this.speciesType,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      audioPath: audioPath ?? this.audioPath,
      conservationStatus: conservationStatus ?? this.conservationStatus,
      habitatType: habitatType ?? this.habitatType,
    );
  }

  @override
  String toString() {
    return 'Observation(id: ' + id.toString() + ', speciesName: ' + speciesName + ', speciesType: ' + speciesType.toString() + ', location: ' + location.toString() + ', dateTime: ' + dateTime.toIso8601String() + ', quantity: ' + quantity.toString() + ', description: ' + description.toString() + ', photoPath: ' + photoPath.toString() + ', audioPath: ' + audioPath.toString() + ', conservationStatus: ' + conservationStatus.toString() + ', habitatType: ' + habitatType.toString() + ')';
  }
} 