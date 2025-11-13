using AutoMapper;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using SafeWalk.WebAPI.Domain.DTOs;
using SafeWalk.WebAPI.Domain.Entities;

namespace SafeWalk.WebAPI.Domain;

public class MappingConfig
{
    /// <summary>
    /// Register the mappings for AutoMapper.
    /// </summary>
    /// <param name="licenceKey">AutoMapper license key</param>
    /// <param name="serviceProvider">Service provider for resolving dependencies like ILoggerFactory</param>
    /// <returns>Mapper config.</returns>
    public static IMapper RegisterMappings(string licenceKey, IServiceProvider serviceProvider)
    {
        var loggerFactory = serviceProvider.GetRequiredService<ILoggerFactory>();
        
        var config = new MapperConfiguration(cfg =>
        {
            cfg.LicenseKey = licenceKey;
            
            cfg.CreateMap<TestEntity, TestDTO>().ReverseMap();
            
            cfg.ConstructServicesUsing(serviceProvider.GetService);
        }, loggerFactory);

        return config.CreateMapper(serviceProvider.GetService);
    }

}