// MapScreen is a placeholder view for the map / navigation feature.
//
// It will eventually display an interactive map with route tracking,
// nearby SafeWalk alerts, and companion location sharing.

import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Map',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Interactive map coming soon.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
