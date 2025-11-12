namespace SafeWalk.WebAPI.Core.Responses;

/// <summary>
/// Represents a single API error detail.
/// </summary>
public sealed record ApiError(string Code, string Message, string? Field = null);

