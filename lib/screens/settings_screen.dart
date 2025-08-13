import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.eco, size: 80, color: Colors.green),
          SizedBox(height: 16),
          Text('Settings will be available soon!', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
} 