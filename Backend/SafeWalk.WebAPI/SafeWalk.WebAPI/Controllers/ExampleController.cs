using Microsoft.AspNetCore.Mvc;
using SafeWalk.WebAPI.Core.Services;

namespace SafeWalk.WebAPI.Controllers;

[Route("api/[controller]")]
public sealed class ExampleController : BaseApiController
{
    private readonly IExampleService _exampleService;

    public ExampleController(IExampleService exampleService)
    {
        _exampleService = exampleService;
    }

    [HttpGet("ok")]
    public IActionResult GetOk()
    {
        var result = _exampleService.GetExample();
        return ToActionResult(result);
    }

    [HttpGet("notfound")]
    public IActionResult GetNotFound()
    {
        var result = _exampleService.GetNotFound();
        return ToActionResult(result);
    }

    [HttpGet("validation-error")]
    public IActionResult GetValidationError()
    {
        var result = _exampleService.GetValidationError();
        return ToActionResult(result);
    }

    [HttpGet("greet/{name?}")]
    public IActionResult GetGreeting(string? name)
    {
        var result = _exampleService.GetGreeting(name);
        return ToActionResult(result);
    }
}
