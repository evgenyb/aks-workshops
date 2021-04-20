using System;
using System.Threading.Tasks;
using Azure;
using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;


namespace api_b.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KeyVaultTestController : ControllerBase
    {
        private readonly ILogger<KeyVaultTestController> _logger;
        private readonly IConfiguration _configuration;
        public KeyVaultTestController(ILogger<KeyVaultTestController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var uri = _configuration["KeyVaultUrl"];
            _logger.LogInformation($"Trying to get secret foobar from {uri} key-vault.");
            var options = new SecretClientOptions()
            {
                Retry =
                {
                    Delay= TimeSpan.FromSeconds(2),
                    MaxDelay = TimeSpan.FromSeconds(16),
                    MaxRetries = 5,
                    Mode = RetryMode.Exponential
                }
            };
            var client = new SecretClient(new Uri(uri), new DefaultAzureCredential(), options);
            var secret = await client.GetSecretAsync("foobar");
            _logger.LogInformation($"foobar: {secret.Value.Value}");
            return Ok($"[api-b.keyvaulttest] - OK");
        }
    }
}