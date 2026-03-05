// Entry point of the SafeWalk application.
//
// Sets up all [ChangeNotifierProvider]s (one per ViewModel) at the top of
// the widget tree, then launches [SafeWalkApp].
//
// Providing ViewModels here ensures they are accessible from every screen
// and their lifecycle is tied to the app's lifetime.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safewalk/app.dart';
import 'package:safewalk/services/api_service.dart';
import 'package:safewalk/viewmodels/home_viewmodel.dart';
import 'package:safewalk/viewmodels/login_viewmodel.dart';
import 'package:safewalk/viewmodels/map_viewmodel.dart';
import 'package:safewalk/viewmodels/contacts_viewmodel.dart';
import 'package:safewalk/viewmodels/settings_viewmodel.dart';

void main() {
  // Shared service instance so all ViewModels use the same API client.
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => ContactsViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const SafeWalkApp(),
    ),
  );
}
