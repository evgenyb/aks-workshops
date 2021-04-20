using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Net.Http;
using System.Threading.Tasks;

namespace api_b.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ApiController : ControllerBase
    {
        private readonly ILogger<ApiController> _logger;
        private readonly IConfiguration _configuration;

        public ApiController(ILogger<ApiController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var apiaServiceUrl = _configuration["ApiAServiceUrl"];
            _logger.LogInformation($"Calling {apiaServiceUrl}...");
            var client = new HttpClient();
            var response = await client.GetAsync(apiaServiceUrl);
            if (response.IsSuccessStatusCode)
            {
                _logger.LogInformation($"Went well...");
            }
            return Ok($"[api-b] - OK");
        }
    }
}
