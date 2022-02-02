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
            var message = "[guinea-pig] - OK.";
            _logger.LogInformation(message);
            return Ok(message);
        }

        [HttpGet("highcpu")]
        public IActionResult HighCpu()
        {
            var sw = Stopwatch.StartNew();
            var x = 0.0001;

            for (var i = 0; i < 2000000; i++)
            {
                x += Math.Sqrt(x);
            }
            sw.Stop();
            _logger.LogInformation($"[guinea-pig.highcpu] - execution took {sw.ElapsedMilliseconds} ms.");
            return Ok();
        }
    }
}
