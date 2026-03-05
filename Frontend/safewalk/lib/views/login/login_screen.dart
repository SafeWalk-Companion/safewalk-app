// LoginScreen provides a combined Login / Registration form.
//
// Users can toggle between the two modes. A "Skip Login" button is provided
// for development convenience while the backend authentication endpoints
// are not yet implemented.
//
// The screen observes [LoginViewModel] to react to state changes
// (loading indicator, status messages, authentication result).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safewalk/viewmodels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to read form field values.
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App title
                const Text(
                  'SafeWalk',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.isRegistering ? 'Create an Account' : 'Welcome Back',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),

                // Username field (only in registration mode)
                if (vm.isRegistering) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : () => _submit(vm),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            vm.isRegistering ? 'Register' : 'Login',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Toggle login / register
                TextButton(
                  onPressed: vm.isLoading ? null : () => vm.toggleMode(),
                  child: Text(
                    vm.isRegistering
                        ? 'Already have an account? Login'
                        : 'No account yet? Register',
                  ),
                ),

                // Skip login (dev convenience)
                TextButton(
                  onPressed: vm.isLoading ? null : () => vm.skipLogin(),
                  child: const Text('Skip Login (Dev)'),
                ),

                // Status message
                if (vm.statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    vm.statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: vm.statusMessage.contains('successful')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reads the form fields and delegates to the ViewModel.
  void _submit(LoginViewModel vm) {
    if (vm.isRegistering) {
      vm.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      vm.login(_emailController.text.trim(), _passwordController.text);
    }
  }
}
