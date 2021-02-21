using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace api_a.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReadinessController : ControllerBase
    {
        private readonly ILogger<ReadinessController> _logger;
        
        public ReadinessController(ILogger<ReadinessController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IActionResult Ready()
        {
            _logger.LogInformation("[api-a] - ready");
            return Ok("[api-a] - ready");
        }
    }
}
