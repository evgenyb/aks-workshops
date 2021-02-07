using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;

namespace api_a
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureAppConfiguration((hostingContext, config) =>
                {
                    config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
                    // 
                    // This is the default way to add configuration file. 
                    // Unfortunately, the build-in reload on changes in .NET core file provider does not work with symlink files. 
                    // The Kubernetes config map does not trigger the configuration reload as one would expect.
                    // Ref. issue https://github.com/dotnet/runtime/issues/36091 
                    //
                    // config.AddJsonFile("config/appsettings.json", optional: true, reloadOnChange: true);
                    // Therefore customizied version of ConfigMapFileProvider from https://github.com/fbeltrao/ConfigMapFileProvider is used here.
                    config.AddJsonFile(ConfigMapFileProvider.FromRelativePath("config"),
                        "appsettings.json",
                        optional: true,
                        reloadOnChange: true);
                    config.AddJsonFile("secrets/appsettings.secrets.json", optional: true);
                })
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });
    }
}
