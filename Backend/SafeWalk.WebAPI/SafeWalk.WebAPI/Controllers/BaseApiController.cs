using Microsoft.AspNetCore.Mvc;
using SafeWalk.WebAPI.Core.Responses;

namespace SafeWalk.WebAPI.Controllers;

/// <summary>
/// Base API controller providing common functionality.
/// </summary>
[ApiController]
[Produces("application/json")]
public abstract class BaseApiController : ControllerBase
{
    /// <summary>
    /// Converts an ApiResponse to an IActionResult.
    /// </summary>
    /// <param name="response">The API response object.</param>
    /// <returns>The action result.</returns>
    protected IActionResult ToActionResult(ApiResponse response)
    {
        return StatusCode(response.StatusCode, response);
    }

    /// <summary>
    /// Converts a generic ApiResponse to an IActionResult.
    /// </summary>
    /// <param name="response">The API response object.</param>
    /// <typeparam name="T">The typename for the data</typeparam>
    /// <returns>The action result.</returns>
    protected IActionResult ToActionResult<T>(ApiResponse<T> response)
    {
        return StatusCode(response.StatusCode, response);
    }
}
