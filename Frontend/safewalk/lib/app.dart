// SafeWalkApp is the root widget of the application.
//
// It configures the global [MaterialApp] theme and decides which screen to
// show based on the authentication state exposed by [LoginViewModel]:
//   - Not authenticated → [LoginScreen]
//   - Authenticated     → [MainShell] (bottom navigation with all tabs)
//
// All ViewModels are provided at this level via [MultiProvider] so that
// every screen in the widget tree can access them.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safewalk/viewmodels/login_viewmodel.dart';
import 'package:safewalk/views/login/login_screen.dart';
import 'package:safewalk/views/main_shell.dart';

class SafeWalkApp extends StatelessWidget {
  const SafeWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeWalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Switch between login and main app based on auth state.
      home: Consumer<LoginViewModel>(
        builder: (context, loginVm, _) {
          if (loginVm.isAuthenticated) {
            return const MainShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
