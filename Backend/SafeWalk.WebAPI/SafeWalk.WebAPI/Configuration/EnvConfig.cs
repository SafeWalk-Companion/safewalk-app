namespace SafeWalk.WebAPI.Configuration;

/// <summary>
/// Helper class to access environment variables from .env file with type safety
/// </summary>
public static class EnvConfig
{
    /// <summary>
    /// Get a required environment variable. Throws if not found.
    /// </summary>
    public static string GetRequired(string key)
    {
        var value = Environment.GetEnvironmentVariable(key);
        if (string.IsNullOrEmpty(value))
        {
            throw new InvalidOperationException($"Required environment variable '{key}' is not set.");
        }
        return value;
    }

    /// <summary>
    /// Get an optional environment variable with a default value.
    /// </summary>
    public static string Get(string key, string defaultValue)
    {
        return Environment.GetEnvironmentVariable(key) ?? defaultValue;
    }

    /// <summary>
    /// Get an environment variable as an integer.
    /// </summary>
    public static int GetInt(string key, int defaultValue)
    {
        var value = Environment.GetEnvironmentVariable(key);
        return int.TryParse(value, out var result) ? result : defaultValue;
    }

    /// <summary>
    /// Get an environment variable as a boolean.
    /// </summary>
    public static bool GetBool(string key, bool defaultValue)
    {
        var value = Environment.GetEnvironmentVariable(key);
        if (string.IsNullOrEmpty(value))
        {
            return defaultValue;
        }
        return value.ToLowerInvariant() is "true" or "1" or "yes";
    }

    /// <summary>
    /// Check if an environment variable exists.
    /// </summary>
    public static bool Has(string key)
    {
        return !string.IsNullOrEmpty(Environment.GetEnvironmentVariable(key));
    }
}