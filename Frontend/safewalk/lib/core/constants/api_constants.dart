// Centralised API configuration so that URLs and endpoints are defined in
// one place and can be changed easily (e.g. for staging vs. production).

class ApiConstants {
  // Prevent instantiation.
  ApiConstants._();

  /// Base URL of the SafeWalk backend API.
  static const String baseUrl =
      'https://0ibq771vuf.execute-api.eu-central-1.amazonaws.com';

  /// Default timeout duration for HTTP requests.
  static const Duration defaultTimeout = Duration(seconds: 10);

  // ---------------------------------------------------------------------------
  // Endpoint paths
  // ---------------------------------------------------------------------------

  /// POST – Register a new platform user.
  static const String registerPlatform = '/register/platform';
}
