using api_b.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
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
        private readonly ICosmosDbService _cosmosDbService;

        public ApiController(ICosmosDbService cosmosDbService, ILogger<ApiController> logger, IConfiguration configuration)
        {
            _cosmosDbService = cosmosDbService;
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
