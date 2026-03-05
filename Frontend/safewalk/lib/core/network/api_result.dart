// ApiResult is a value object that represents the outcome of an HTTP request.
//
// Every API call returns an [ApiResult] so that callers can uniformly check
// [isSuccess], inspect the [statusCode], read parsed [data], or display an
// error [message].

class ApiResult {
  /// Whether the request completed with a 2xx status code.
  final bool isSuccess;

  /// The HTTP status code returned by the server (0 for network errors).
  final int statusCode;

  /// A human-readable message — "Success" on success, error details otherwise.
  final String? message;

  /// The parsed response body (usually a Map or List from JSON).
  final dynamic data;

  /// The raw, unparsed response body string (only present on success).
  final String? rawBody;

  ApiResult({
    required this.isSuccess,
    required this.statusCode,
    this.message,
    this.data,
    this.rawBody,
  });

  /// Factory for a successful result.
  factory ApiResult.success({
    required int statusCode,
    dynamic data,
    String? rawBody,
  }) {
    return ApiResult(
      isSuccess: true,
      statusCode: statusCode,
      data: data,
      rawBody: rawBody,
      message: 'Success',
    );
  }

  /// Factory for an error result.
  factory ApiResult.error({
    required int statusCode,
    required String message,
    dynamic data,
  }) {
    return ApiResult(
      isSuccess: false,
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }

  @override
  String toString() =>
      'ApiResult(isSuccess: $isSuccess, statusCode: $statusCode, '
      'message: $message, data: $data)';
}
