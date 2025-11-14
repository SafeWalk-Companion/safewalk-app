import 'dart:convert';
import 'package:http/http.dart' as http;

/// A general-purpose HTTP request controller following OpenAPI standards.
/// Provides safe methods for making HTTP requests with proper error handling.
class RequestController {
  final String baseUrl;
  final Duration timeout;

  RequestController({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
  });

  /// Makes a GET request to the specified endpoint.
  ///
  /// Returns a [RequestResult] containing either the successful response
  /// or error information if the request fails.
  ///
  /// Parameters:
  /// - [endpoint]: The API endpoint path (e.g., '/api/example/ok')
  /// - [headers]: Optional HTTP headers to include in the request
  /// - [queryParameters]: Optional query parameters for the URL
  Future<RequestResult> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await http
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return RequestResult.error(
        statusCode: 0,
        message: 'Request failed: ${e.toString()}',
      );
    }
  }

  /// Makes a POST request to the specified endpoint.
  ///
  /// Returns a [RequestResult] containing either the successful response
  /// or error information if the request fails.
  ///
  /// Parameters:
  /// - [endpoint]: The API endpoint path
  /// - [body]: The request body (will be JSON encoded)
  /// - [headers]: Optional HTTP headers to include in the request
  Future<RequestResult> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return RequestResult.error(
        statusCode: 0,
        message: 'Request failed: ${e.toString()}',
      );
    }
  }

  /// Makes a PUT request to the specified endpoint.
  ///
  /// Returns a [RequestResult] containing either the successful response
  /// or error information if the request fails.
  ///
  /// Parameters:
  /// - [endpoint]: The API endpoint path
  /// - [body]: The request body (will be JSON encoded)
  /// - [headers]: Optional HTTP headers to include in the request
  Future<RequestResult> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final response = await http
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return RequestResult.error(
        statusCode: 0,
        message: 'Request failed: ${e.toString()}',
      );
    }
  }

  /// Makes a DELETE request to the specified endpoint.
  ///
  /// Returns a [RequestResult] containing either the successful response
  /// or error information if the request fails.
  ///
  /// Parameters:
  /// - [endpoint]: The API endpoint path
  /// - [headers]: Optional HTTP headers to include in the request
  Future<RequestResult> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final response = await http
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return RequestResult.error(
        statusCode: 0,
        message: 'Request failed: ${e.toString()}',
      );
    }
  }

  /// Builds a URI from the base URL and endpoint with optional query parameters.
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final fullUrl = '$baseUrl$endpoint';
    final uri = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    return uri;
  }

  /// Builds HTTP headers with default Content-Type for JSON.
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Handles the HTTP response and converts it to a RequestResult.
  RequestResult _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return RequestResult.success(
        statusCode: response.statusCode,
        data: _parseResponseBody(response.body),
        rawBody: response.body,
      );
    } else {
      return RequestResult.error(
        statusCode: response.statusCode,
        message: 'Request failed with status ${response.statusCode}',
        data: _parseResponseBody(response.body),
      );
    }
  }

  /// Safely parses the response body as JSON.
  dynamic _parseResponseBody(String body) {
    if (body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (e) {
      return body;
    }
  }
}

/// Represents the result of an HTTP request.
class RequestResult {
  final bool isSuccess;
  final int statusCode;
  final String? message;
  final dynamic data;
  final String? rawBody;

  RequestResult({
    required this.isSuccess,
    required this.statusCode,
    this.message,
    this.data,
    this.rawBody,
  });

  /// Creates a successful request result.
  factory RequestResult.success({
    required int statusCode,
    dynamic data,
    String? rawBody,
  }) {
    return RequestResult(
      isSuccess: true,
      statusCode: statusCode,
      data: data,
      rawBody: rawBody,
      message: 'Success',
    );
  }

  /// Creates an error request result.
  factory RequestResult.error({
    required int statusCode,
    required String message,
    dynamic data,
  }) {
    return RequestResult(
      isSuccess: false,
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }

  @override
  String toString() {
    return 'RequestResult(isSuccess: $isSuccess, statusCode: $statusCode, message: $message, data: $data)';
  }
}
