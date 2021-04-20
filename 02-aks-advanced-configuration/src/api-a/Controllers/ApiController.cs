using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace api_a.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ApiController : ControllerBase
    {
        private readonly ILogger<ApiController> _logger;

        public ApiController(ILogger<ApiController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IActionResult Get()
        {
            _logger.LogInformation("[api-a] - OK.");
            return Ok("[api-a] - OK.");
        }
    }
}
