using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace SafeWalk.WebAPI.Composition;

public interface IServiceModule
{
    /// <summary>
    /// Configure services for the module.
    /// </summary>
    void ConfigureServices(IServiceCollection services, IConfiguration configuration);
}