using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SafeWalk.WebAPI.Core.Services;

namespace SafeWalk.WebAPI.Composition.Modules;

/// <summary>
/// DI module for registering core services.
/// </summary>
public class CoreModule : IServiceModule
{
    public void ConfigureServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<IExampleService, ExampleService>();
    }
}