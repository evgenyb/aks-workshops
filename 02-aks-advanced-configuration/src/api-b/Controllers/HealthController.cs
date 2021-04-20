using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace api_b.Controllers
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
            //_logger.LogDebug("[api-b] - healthy");
            return Ok("[api-b] - healthy");
        }
    }
}
