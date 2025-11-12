using System.Net;

namespace SafeWalk.WebAPI.Core.Responses;

/// <summary>
/// Base API response that carries success flag, status and optional error details.
/// </summary>
public record ApiResponse
{
    public required bool Success { get; init; }
    public required int StatusCode { get; init; }
    public string? Message { get; init; }
    public IReadOnlyList<ApiError>? Errors { get; init; }

    /// <summary>
    /// Creates a successful API response with optional message.
    /// </summary>
    /// <param name="message">The message.</param>
    /// <returns>The API response</returns>
    public static ApiResponse Ok(string? message = null) => new()
    {
        Success = true,
        StatusCode = (int)HttpStatusCode.OK,
        Message = message
    };

    /// <summary>
    /// Creates a successful API response indicating resource creation.
    /// </summary>
    /// <param name="message">The message.</param>
    /// <returns>The API response</returns>
    public static ApiResponse Created(string? message = null) => new()
    {
        Success = true,
        StatusCode = (int)HttpStatusCode.Created,
        Message = message
    };

    /// <summary>
    /// Creates a failed API response with status, optional message and error details.
    /// </summary>
    /// <param name="status">The status code.</param>
    /// <param name="message">The message.</param>
    /// <param name="errors">The errors.</param>
    /// <returns>The API response</returns>
    public static ApiResponse Fail(HttpStatusCode status, string? message = null, IEnumerable<ApiError>? errors = null) => new()
    {
        Success = false,
        StatusCode = (int)status,
        Message = message,
        Errors = errors?.ToList()
    };
}

/// <summary>
/// Generic API response which also carries a value when successful.
/// </summary>
public sealed record ApiResponse<T> : ApiResponse
{
    public T? Data { get; init; }

    /// <summary>
    /// Creates a successful API response with data and optional message.
    /// </summary>
    /// <param name="data">The data object.</param>
    /// <param name="message">The message.</param>
    /// <returns>The API response</returns>
    public static ApiResponse<T> Ok(T data, string? message = null) => new()
    {
        Success = true,
        StatusCode = (int)HttpStatusCode.OK,
        Message = message,
        Data = data
    };

    /// <summary>
    /// Creates a successful API response indicating resource creation with data.
    /// </summary>
    /// <param name="data">The data object.</param>
    /// <param name="message">The messsage.</param>
    /// <returns>The API response</returns>
    public static ApiResponse<T> Created(T data, string? message = null) => new()
    {
        Success = true,
        StatusCode = (int)HttpStatusCode.Created,
        Message = message,
        Data = data
    };

    /// <summary>
    /// Creates a failed API response with status, optional message and error details.
    /// </summary>
    /// <param name="status">The status code.</param>
    /// <param name="message">The message.</param>
    /// <param name="errors">The errors.</param>
    /// <returns>The API response</returns>
    public new static ApiResponse<T> Fail(HttpStatusCode status, string? message = null, IEnumerable<ApiError>? errors = null) => new()
    {
        Success = false,
        StatusCode = (int)status,
        Message = message,
        Errors = errors?.ToList(),
        Data = default
    };
}
