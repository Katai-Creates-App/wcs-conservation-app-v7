import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/observation.dart';
import '../providers/observation_provider.dart';
import 'observation_form_screen.dart';
import 'dart:io';

class ObservationDetailScreen extends StatelessWidget {
  final Observation observation;
  const ObservationDetailScreen({Key? key, required this.observation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ObservationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(observation.speciesName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ObservationFormScreen(observation: observation),
                ),
              );
              
              if (result == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Observation saved!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Observation'),
                  content: const Text('Are you sure you want to delete this observation?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                await provider.deleteObservation(observation.id!);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            observation.photoPath != null
                ? Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(observation.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            observation.speciesType == SpeciesType.plant ? Icons.local_florist : Icons.pets,
                            size: 100,
                            color: Colors.green,
                          );
                        },
                      ),
                    ),
                  )
                : Icon(observation.speciesType == SpeciesType.plant ? Icons.local_florist : Icons.pets, size: 100, color: Colors.green),
            const SizedBox(height: 16),
            _buildDetailRow('Species Name', observation.speciesName),
            _buildDetailRow('Type', observation.speciesType.name),
            _buildDetailRow('Location', observation.location ?? '-'),
            _buildDetailRow('Date', observation.dateTime.toString()),
            _buildDetailRow('Quantity', observation.quantity.toString()),
            _buildDetailRow('Status', observation.conservationStatus.name),
            _buildDetailRow('Habitat', observation.habitatType.name),
            _buildDetailRow('Description', observation.description ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 