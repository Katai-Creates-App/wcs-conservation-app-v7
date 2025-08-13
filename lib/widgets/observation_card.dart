import 'package:flutter/material.dart';
import '../models/observation.dart';
import '../screens/observation_detail_screen.dart';

class ObservationCard extends StatelessWidget {
  final Observation observation;
  final VoidCallback? onTap;

  const ObservationCard({
    Key? key,
    required this.observation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ObservationDetailScreen(observation: observation),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSpeciesIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          observation.speciesName,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(),
                            const SizedBox(width: 8),
                            _buildTypeChip(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildQuantityBadge(context),
                ],
              ),
              if (observation.description != null && observation.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  observation.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(observation.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    observation.habitatType.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeciesIcon() {
    final isPlant = observation.speciesType == SpeciesType.plant;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isPlant ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isPlant ? Icons.local_florist : Icons.pets,
        color: isPlant ? Colors.green[700] : Colors.blue[700],
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (observation.conservationStatus) {
      case ConservationStatus.healthy:
        color = Colors.green;
        break;
      case ConservationStatus.threatened:
        color = Colors.orange;
        break;
      case ConservationStatus.endangered:
        color = Colors.red;
        break;
      case ConservationStatus.critical:
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        observation.conservationStatus.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    final isPlant = observation.speciesType == SpeciesType.plant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPlant ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlant ? Colors.green[200]! : Colors.blue[200]!,
        ),
      ),
      child: Text(
        observation.speciesType.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isPlant ? Colors.green[700] : Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildQuantityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${observation.quantity}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
} 