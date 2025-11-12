using System.Net;
using SafeWalk.WebAPI.Core.Responses;

namespace SafeWalk.WebAPI.Core.Services;

/// <summary>
/// Example implementation of IExampleService.
/// </summary>
public sealed class ExampleService : IExampleService
{
    public ApiResponse<object> GetExample()
    {
        var payload = new { Example = "value" };
        return ApiResponse<object>.Ok(payload, "Request succeeded");
    }

    public ApiResponse GetNotFound()
    {
        return ApiResponse.Fail(HttpStatusCode.NotFound, "Resource not found");
    }

    public ApiResponse GetValidationError()
    {
        var errors = new[] { new ApiError("required", "Name is required", "name") };
        return ApiResponse.Fail(HttpStatusCode.BadRequest, "Validation failed", errors);
    }

    public ApiResponse<string> GetGreeting(string? name)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            var errors = new[] { new ApiError("required", "Name is required", "name") };
            return ApiResponse<string>.Fail(HttpStatusCode.BadRequest, "Validation failed", errors);
        }

        return ApiResponse<string>.Ok($"Hello, {name}!", "Greeting generated");
    }
}

