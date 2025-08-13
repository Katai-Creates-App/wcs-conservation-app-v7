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
      'conservation_status': conservationStatus.index,
      'habitat_type': habitatType.index,
    };
  }
} 