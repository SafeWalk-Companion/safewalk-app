// filepath: /Users/UYRW0IO/Documents/Projects/safewalk-app/Backend/SafeWalk.WebAPI/SafeWalk.WebAPI.Core/Services/IExampleService.cs
using SafeWalk.WebAPI.Core.Responses;
using SafeWalk.WebAPI.Domain.DTOs;

namespace SafeWalk.WebAPI.Core.Services;

/// <summary>
/// Example service interface defining various API response methods.
/// </summary>
public interface IExampleService : ICoreService
{
    ApiResponse<TestDTO> GetExample();
    ApiResponse GetNotFound();
    ApiResponse GetValidationError();
    ApiResponse<string> GetGreeting(string? name);
}

