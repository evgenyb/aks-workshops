using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace api_a.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class HealthController : ControllerBase
    {
        private readonly ILogger<HealthController> _logger;
        
        public HealthController(ILogger<HealthController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IActionResult Healthy()
        {
            _logger.LogInformation("[api-a] - healthy");
            return Ok("[api-a] - healthy");
        }
    }
}
