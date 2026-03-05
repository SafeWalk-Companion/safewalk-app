// LoginViewModel manages state for the Login / Registration screen.
//
// It holds form field values, validates input, and triggers authentication
// calls via [ApiService]. The View observes this ViewModel through
// [ChangeNotifier].

import 'package:flutter/foundation.dart';
import 'package:safewalk/services/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService;

  LoginViewModel({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // ---------------------------------------------------------------------------
  // Observable state
  // ---------------------------------------------------------------------------

  /// Whether the UI is showing the registration form (true) or login form.
  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;

  /// Status / error message displayed below the form.
  String _statusMessage = '';
  String get statusMessage => _statusMessage;

  /// Whether an auth request is in flight.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Whether the user has been authenticated successfully.
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Toggles between login and registration mode.
  void toggleMode() {
    _isRegistering = !_isRegistering;
    _statusMessage = '';
    notifyListeners();
  }

  /// Attempts to log in with the given credentials.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _statusMessage = '';
    notifyListeners();

    final result = await _apiService.login(email, password);

    if (result.isSuccess) {
      _isAuthenticated = true;
      _statusMessage = 'Login successful!';
    } else {
      _statusMessage = result.message ?? 'Login failed.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Attempts to register a new account.
  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _statusMessage = '';
    notifyListeners();

    final result = await _apiService.register(username, email, password);

    if (result.isSuccess) {
      _statusMessage = 'Registration successful! You can now log in.';
      _isRegistering = false;
    } else {
      _statusMessage = result.message ?? 'Registration failed.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Skips authentication (for development / testing purposes).
  void skipLogin() {
    _isAuthenticated = true;
    notifyListeners();
  }
}
