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
            _logger.LogInformation("[lab-05 task #4] - always ready");
            return Ok("[lab-05 task #4] - always ready");
        }

        [HttpGet("unstable")]
        // readiness/unstable
        public IActionResult Unstable()
        {
            // This endpoint will change the return status from 200 to 500 every minute
            var minutesFromStart = Timekeeper.GetMinutesFromStart();
            if (minutesFromStart % 2 != 0)
            {
                _logger.LogInformation($"{minutesFromStart} min from the start -> response with 200");
                return Ok("[lab-05 task #5] - ready");
            }
            else
            {
                _logger.LogInformation($"{minutesFromStart} min from the start -> response with 500");
                return StatusCode(500);
}
        }
    }
}
