// ContactsScreen is a placeholder view for the contacts feature.
//
// It will eventually display the user's emergency contacts and allow
// adding, editing, or removing contacts.

import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Contacts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Emergency contacts management coming soon.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
