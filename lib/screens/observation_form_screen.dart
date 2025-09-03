import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/observation.dart';
import '../providers/observation_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ObservationFormScreen extends StatefulWidget {
  final Observation? observation;
  final VoidCallback? onSaveSuccess;
  const ObservationFormScreen({Key? key, this.observation, this.onSaveSuccess}) : super(key: key);

  @override
  State<ObservationFormScreen> createState() => _ObservationFormScreenState();
}

class _ObservationFormScreenState extends State<ObservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late String _speciesName;
  SpeciesType _speciesType = SpeciesType.plant;
  String? _location;
  DateTime _dateTime = DateTime.now();
  int _quantity = 1;
  String? _description;
  String? _photoPath;
  ConservationStatus _conservationStatus = ConservationStatus.healthy;
  HabitatType _habitatType = HabitatType.forest;

  @override
  void initState() {
    super.initState();
    if (widget.observation != null) {
      final obs = widget.observation!;
      _speciesName = obs.speciesName;
      _speciesType = obs.speciesType;
      _location = obs.location;
      _dateTime = obs.dateTime;
      _quantity = obs.quantity;
      _description = obs.description;
      _photoPath = obs.photoPath;
      _conservationStatus = obs.conservationStatus;
      _habitatType = obs.habitatType;
    } else {
      _speciesName = '';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateTime = picked;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _photoPath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _photoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gallery error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        final obs = Observation(
          id: widget.observation?.id,
          speciesName: _speciesName,
          speciesType: _speciesType,
          location: _location,
          dateTime: _dateTime,
          quantity: _quantity,
          description: _description,
          photoPath: _photoPath,
          conservationStatus: _conservationStatus,
          habitatType: _habitatType,
        );
        final provider = Provider.of<ObservationProvider>(context, listen: false);
        
        bool success = false;
        if (widget.observation == null) {
          success = await provider.addObservation(obs);
        } else {
          success = await provider.updateObservation(obs);
        }
        
        if (mounted) {
          if (success) {
            // If we have a callback, use it; otherwise use Navigator.pop
            if (widget.onSaveSuccess != null) {
              widget.onSaveSuccess!();
            } else {
              Navigator.pop(context, true);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Failed to save observation'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.observation == null ? 'Add Observation' : 'Edit Observation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Species Information Group
              const Text(
                'Species Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: _speciesName,
                  decoration: const InputDecoration(
                    labelText: 'Species Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.nature),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _speciesName = val!,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<SpeciesType>(
                  value: _speciesType,
                  decoration: const InputDecoration(
                    labelText: 'Species Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: SpeciesType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                  )).toList(),
                  onChanged: (val) => setState(() => _speciesType = val!),
                ),
              ),
              const SizedBox(height: 24),
              
              // Location and Date Group
              const Text(
                'Location & Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: _location,
                  decoration: const InputDecoration(
                    labelText: 'Location (GPS or manual)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onSaved: (val) => _location = val,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  title: Text('Date: ${DateFormat.yMMMd().format(_dateTime)}'),
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  trailing: ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Select Date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Quantity and Description Group
              const Text(
                'Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: _quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    final n = int.tryParse(val);
                    if (n == null || n < 1) return 'Must be positive';
                    return null;
                  },
                  onSaved: (val) => _quantity = int.parse(val!),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(
                    labelText: 'Description/Notes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  onSaved: (val) => _description = val,
                ),
              ),
              const SizedBox(height: 24),
              
              // Photo Section
              const Text(
                'Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('📸 Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('📁 Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (_photoPath != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error,
                            size: 48,
                            color: Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _photoPath = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              
              // Conservation Information Group
              const Text(
                'Conservation Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<ConservationStatus>(
                  value: _conservationStatus,
                  decoration: const InputDecoration(
                    labelText: 'Conservation Status *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.eco),
                  ),
                  items: ConservationStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.name[0].toUpperCase() + status.name.substring(1)),
                  )).toList(),
                  onChanged: (val) => setState(() => _conservationStatus = val!),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<HabitatType>(
                  value: _habitatType,
                  decoration: const InputDecoration(
                    labelText: 'Habitat Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.landscape),
                  ),
                  items: HabitatType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                  )).toList(),
                  onChanged: (val) => setState(() => _habitatType = val!),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await _saveForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.observation == null ? 'Add Observation' : 'Save Changes',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 