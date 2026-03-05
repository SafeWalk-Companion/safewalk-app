// HomeScreen displays the SafeWalk API connection test.
//
// This is the main landing page after login. It lets the user press a button
// to verify backend connectivity and displays the raw API response.
// The screen observes [HomeViewModel] via [ChangeNotifierProvider] and
// rebuilds automatically when the ViewModel state changes.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safewalk/viewmodels/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the HomeViewModel provided higher up in the widget tree.
    final vm = context.watch<HomeViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          const Text(
            'SafeWalk API Test',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Test button
          ElevatedButton(
            onPressed: vm.isLoading ? null : () => vm.testApiConnection(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: vm.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Test API Connection',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
          const SizedBox(height: 30),

          // Response label
          const Text(
            'Response:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Response body
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  vm.responseText,
                  style: const TextStyle(fontSize: 14, fontFamily: 'Courier'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
