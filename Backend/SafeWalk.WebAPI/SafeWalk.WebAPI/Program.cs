using AutoMapper;
using DotNetEnv;
using Microsoft.OpenApi.Models;
using SafeWalk.WebAPI.Composition;
using SafeWalk.WebAPI.Composition.Modules;
using SafeWalk.WebAPI.Configuration;
using SafeWalk.WebAPI.Domain;

namespace SafeWalk.WebAPI;

public class Program
{
    public static void Main(string[] args)
    {
        // Load environment variables from .env file
        Env.Load();
        
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.

        builder.Services.AddControllers();
        builder.Services.AddOpenApi();
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(sgo =>
        {
            var serverUrl = EnvConfig.Get("API_SERVER_URL", "http://localhost:5175");
            sgo.AddServer(new OpenApiServer { Url = serverUrl });
        });

        // Register middlewares
        builder.Services.AddCors(opt =>
        {
            opt.AddDefaultPolicy(bld =>
            {
                bld
                    .SetIsOriginAllowed(origin => true)
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .AllowCredentials()
                    .WithHeaders("Access-Control-Allow-Origin");
            });
        });

        builder.Services.AddSingleton<IMapper>(sp => 
            MappingConfig.RegisterMappings(EnvConfig.GetRequired("AUTOMAPPER_LICENSE_KEY"), sp));
        
        // Register services
        List<IServiceModule> serviceModules = new List<IServiceModule> { new CoreModule() };

        foreach (var module in serviceModules)
        {
            module.ConfigureServices(builder.Services, builder.Configuration);
        }
        
        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
            app.UseSwagger();
            app.UseSwaggerUI();
        }
        
        app.UseNoCacheHttpHeaders();
        app.UseHsts(hsts => hsts.MaxAge(30).IncludeSubdomains());
        app.UseXContentTypeOptions();
        app.UseReferrerPolicy(referrerPolicy => referrerPolicy.NoReferrer());
        app.UseXXssProtection(xssProtection => xssProtection.EnabledWithBlockMode());
        app.UseXfo(opts => opts.Deny());
        app.UseHttpsRedirection();

        app.UseCors();

        app.UseAuthentication();
        app.UseAuthorization();
        
        app.MapControllers();

        app.Run();
    }
}