using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace IaC.WS5.GuineaPig.Controllers
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

        [HttpGet("highcpu")]
        // readiness/unstable
        public IActionResult HighCpu()
        {
            var x = 0.0001;

            for (var i = 0; i < 2000000; i++)
            {
                x += Math.Sqrt(x);
            }
            return Ok();
        }
    }
}
