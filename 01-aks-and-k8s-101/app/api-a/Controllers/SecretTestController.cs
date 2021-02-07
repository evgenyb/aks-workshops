using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace api_a.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SecretTestController : ControllerBase
    {
        private readonly ILogger<SecretTestController> _logger;
        private readonly IConfiguration Configuration;

        public SecretTestController(ILogger<SecretTestController> logger, IConfiguration configuration)
        {
            _logger = logger;
            Configuration = configuration;
        }

        [HttpGet]
        public IActionResult Get()
        {
            _logger.LogInformation($"[lab-08] - Database:ConnectionString: {Configuration["Database:ConnectionString"]}");
            return Ok("[lab-08] - OK");
        }
    }
}
