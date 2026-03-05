// ApiClient provides a general-purpose HTTP client for communicating with
// REST APIs. It wraps the `http` package and offers typed methods for
// GET, POST, PUT, and DELETE requests with consistent error handling,
// timeout support, and JSON serialization.
//
// Usage:
//   final client = ApiClient(baseUrl: 'https://api.example.com');
//   final result = await client.get('/users');

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safewalk/core/network/api_result.dart';

class ApiClient {
  /// The base URL all requests are made against (e.g. https://api.example.com).
  final String baseUrl;

  /// Maximum duration to wait for a response before timing out.
  final Duration timeout;

  ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
  });

  // ---------------------------------------------------------------------------
  // Public HTTP methods
  // ---------------------------------------------------------------------------

  /// Sends a GET request to [endpoint].
  ///
  /// Optional [headers] are merged with the default JSON headers.
  /// Optional [queryParameters] are appended to the URL.
  Future<ApiResult> get(
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
      return ApiResult.error(
        statusCode: 0,
        message: 'GET request failed: ${e.toString()}',
      );
    }
  }

  /// Sends a POST request to [endpoint] with an optional JSON [body].
  Future<ApiResult> post(
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
      return ApiResult.error(
        statusCode: 0,
        message: 'POST request failed: ${e.toString()}',
      );
    }
  }

  /// Sends a PUT request to [endpoint] with an optional JSON [body].
  Future<ApiResult> put(
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
      return ApiResult.error(
        statusCode: 0,
        message: 'PUT request failed: ${e.toString()}',
      );
    }
  }

  /// Sends a DELETE request to [endpoint].
  Future<ApiResult> delete(
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
      return ApiResult.error(
        statusCode: 0,
        message: 'DELETE request failed: ${e.toString()}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Constructs a full [Uri] from the [baseUrl], [endpoint], and optional
  /// [queryParameters].
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  /// Merges default JSON headers with any [customHeaders].
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

  /// Converts an [http.Response] into an [ApiResult].
  ApiResult _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResult.success(
        statusCode: response.statusCode,
        data: _parseBody(response.body),
        rawBody: response.body,
      );
    } else {
      return ApiResult.error(
        statusCode: response.statusCode,
        message: 'Request failed with status ${response.statusCode}',
        data: _parseBody(response.body),
      );
    }
  }

  /// Tries to parse [body] as JSON; returns the raw string on failure.
  dynamic _parseBody(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
