import 'package:safewalk/components/requests/requestcontroller.dart';

/// TestController handles test API requests to the backend.
/// Specifically designed for testing connectivity with the SafeWalk API.
class TestController {
  late final RequestController _requestController;

  TestController({String? baseUrl}) {
    _requestController = RequestController(
      baseUrl: baseUrl ?? 'http://localhost:5175',
      timeout: const Duration(seconds: 10),
    );
  }

  /// Tests the API connection by making a GET request to /api/Example/ok
  ///
  /// Returns a [RequestResult] containing:
  /// - On success: The JSON response from the server
  /// - On failure: Error information with status code and message
  ///
  /// This method safely handles all errors including:
  /// - Network connectivity issues
  /// - Timeout errors
  /// - Server errors
  /// - Invalid responses
  Future<RequestResult> testOkEndpoint() async {
    try {
      final result = await _requestController.get('/api/Example/ok');
      return result;
    } catch (e) {
      // Additional error handling wrapper for extra safety
      return RequestResult.error(
        statusCode: 0,
        message: 'Unexpected error in testOkEndpoint: ${e.toString()}',
      );
    }
  }

  /// Gets the example data formatted as a readable string.
  /// Returns a user-friendly message with the response data or error.
  Future<String> testAndGetFormattedResponse() async {
    final result = await testOkEndpoint();

    if (result.isSuccess) {
      return 'Success! Status: ${result.statusCode}\n\n'
          'Response:\n${result.rawBody ?? result.data.toString()}';
    } else {
      return 'Error! Status: ${result.statusCode}\n\n'
          'Message: ${result.message}\n'
          '${result.data != null ? 'Data: ${result.data}' : ''}';
    }
  }
}
