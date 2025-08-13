import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/observation.dart';
import '../providers/observation_provider.dart';
import 'package:intl/intl.dart';

class ObservationFormScreen extends StatefulWidget {
  final Observation? observation;
  final VoidCallback? onSaveSuccess;
  const ObservationFormScreen({Key? key, this.observation, this.onSaveSuccess}) : super(key: key);

  @override
  State<ObservationFormScreen> createState() => _ObservationFormScreenState();
}

class _ObservationFormScreenState extends State<ObservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
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
              TextFormField(
                initialValue: _speciesName,
                decoration: const InputDecoration(labelText: 'Species Name *'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _speciesName = val!,
              ),
              DropdownButtonFormField<SpeciesType>(
                value: _speciesType,
                decoration: const InputDecoration(labelText: 'Species Type *'),
                items: SpeciesType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                )).toList(),
                onChanged: (val) => setState(() => _speciesType = val!),
              ),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Location (GPS or manual)'),
                onSaved: (val) => _location = val,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Date: ${DateFormat.yMMMd().format(_dateTime)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: const InputDecoration(labelText: 'Quantity *'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  final n = int.tryParse(val);
                  if (n == null || n < 1) return 'Must be positive';
                  return null;
                },
                onSaved: (val) => _quantity = int.parse(val!),
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description/Notes'),
                maxLines: 3,
                onSaved: (val) => _description = val,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Photo (simulated)'),
                trailing: _photoPath == null
                    ? IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: () {
                          setState(() {
                            _photoPath = 'assets/placeholder.png';
                          });
                        },
                      )
                    : Image.asset('assets/placeholder.png', width: 48, height: 48),
              ),
              DropdownButtonFormField<ConservationStatus>(
                value: _conservationStatus,
                decoration: const InputDecoration(labelText: 'Conservation Status *'),
                items: ConservationStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.name[0].toUpperCase() + status.name.substring(1)),
                )).toList(),
                onChanged: (val) => setState(() => _conservationStatus = val!),
              ),
              DropdownButtonFormField<HabitatType>(
                value: _habitatType,
                decoration: const InputDecoration(labelText: 'Habitat Type *'),
                items: HabitatType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                )).toList(),
                onChanged: (val) => setState(() => _habitatType = val!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _saveForm();
                },
                child: Text(widget.observation == null ? 'Add Observation' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 