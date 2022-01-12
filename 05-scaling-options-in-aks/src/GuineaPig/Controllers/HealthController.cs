using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace IaC.WS5.GuineaPig.Controllers
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
            return Ok("[guinea-pig] - healthy");
        }
    }
}
