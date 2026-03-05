// HomeViewModel manages the state and business logic for the Home screen.
//
// It exposes observable properties via [ChangeNotifier] so that the View
// (HomeScreen) can rebuild automatically when data changes. The ViewModel
// delegates network calls to [ApiService] and never references UI widgets.

import 'package:flutter/foundation.dart';
import 'package:safewalk/services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService;

  HomeViewModel({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // ---------------------------------------------------------------------------
  // Observable state
  // ---------------------------------------------------------------------------

  /// Text displayed in the response area.
  String _responseText = 'Press the button to test the API connection';
  String get responseText => _responseText;

  /// Whether a network request is currently in flight.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Tests the connection to the SafeWalk backend and updates [responseText].
  Future<void> testApiConnection() async {
    _isLoading = true;
    _responseText = 'Loading...';
    notifyListeners();

    try {
      final result = await _apiService.testConnection();

      if (result.isSuccess) {
        _responseText =
            'Success! Status: ${result.statusCode}\n\n'
            'Response:\n${result.rawBody ?? result.data.toString()}';
      } else {
        _responseText =
            'Error! Status: ${result.statusCode}\n\n'
            'Message: ${result.message}\n'
            '${result.data != null ? 'Data: ${result.data}' : ''}';
      }
    } catch (e) {
      _responseText = 'Unexpected error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
