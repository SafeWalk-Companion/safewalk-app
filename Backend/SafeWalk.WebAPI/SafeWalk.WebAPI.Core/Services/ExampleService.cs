using System.Net;
using AutoMapper;
using SafeWalk.WebAPI.Core.Responses;
using SafeWalk.WebAPI.Domain.DTOs;
using SafeWalk.WebAPI.Domain.Entities;

namespace SafeWalk.WebAPI.Core.Services;

/// <summary>
/// Example implementation of IExampleService.
/// </summary>
public sealed class ExampleService : IExampleService
{
    private readonly IMapper Mapper;
    
    public ExampleService(IMapper mapper)
    {
        Mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
    }
    
    public ApiResponse<TestDTO> GetExample()
    {
        TestEntity testEntity = new TestEntity() { Id = 1, Name = "Test" };
        TestDTO testDto = Mapper.Map<TestDTO>(testEntity);
        
        return ApiResponse<TestDTO>.Ok(testDto, "Request succeeded");
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

