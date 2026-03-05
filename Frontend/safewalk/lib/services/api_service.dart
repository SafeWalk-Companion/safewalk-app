// ApiService acts as the **service layer** between ViewModels and the network.
//
// It uses [ApiClient] to perform HTTP calls and exposes domain-specific
// methods (e.g. `testConnection`, `login`) so that ViewModels never deal
// with raw endpoints or request construction directly.

import 'package:safewalk/core/constants/api_constants.dart';
import 'package:safewalk/core/network/api_client.dart';
import 'package:safewalk/core/network/api_result.dart';

class ApiService {
  late final ApiClient _client;

  ApiService({ApiClient? client}) {
    _client =
        client ??
        ApiClient(
          baseUrl: ApiConstants.baseUrl,
          timeout: ApiConstants.defaultTimeout,
        );
  }

  // ---------------------------------------------------------------------------
  // Connection test
  // ---------------------------------------------------------------------------

  /// Sends a test POST request to the registration endpoint to verify that
  /// the backend is reachable.
  Future<ApiResult> testConnection() async {
    return _client.post(
      ApiConstants.registerPlatform,
      body: {'userId': '123456789'},
    );
  }

  // ---------------------------------------------------------------------------
  // Authentication (placeholder – implement when backend is ready)
  // ---------------------------------------------------------------------------

  /// Logs a user in with [email] and [password].
  /// Returns an [ApiResult] with user data on success.
  Future<ApiResult> login(String email, String password) async {
    // TODO: Replace with actual login endpoint when available.
    return ApiResult.error(
      statusCode: 501,
      message: 'Login endpoint not yet implemented on the backend.',
    );
  }

  /// Registers a new user account.
  Future<ApiResult> register(
    String username,
    String email,
    String password,
  ) async {
    // TODO: Replace with actual registration endpoint when available.
    return ApiResult.error(
      statusCode: 501,
      message: 'Registration endpoint not yet implemented on the backend.',
    );
  }
}
