using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace api_b.Controllers
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
            _logger.LogInformation("[api-b] - ready");
            return Ok("[api-b] - ready");
        }
    }
}
