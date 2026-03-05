// SettingsScreen is a placeholder view for app settings.
//
// It will eventually allow the user to configure notifications,
// appearance, account details, and other preferences.

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'App settings coming soon.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
