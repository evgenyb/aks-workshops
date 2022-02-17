using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Prometheus;

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

        private static readonly Counter FailedHighCpuCalls = Metrics
            .CreateCounter("guinea_pig_highcpu_failed_total", "Number of highcpu operations that failed.");
        
        private readonly Random _random = new Random();
        
        [HttpGet("highcpu")]
        public IActionResult HighCpu()
        {
            return FailedHighCpuCalls.CountExceptions(ExecuteHighCpu);
        }

        private IActionResult ExecuteHighCpu()
        {
            var random = _random.Next(0, 100);
            if (random < 10) throw new Exception("[guinea-pig: random exception]");
            if (random > 10 & random < 30) return NotFound("not found");
            
            var sw = Stopwatch.StartNew();
            var x = 0.0001;

            for (var i = 0; i < 2000000; i++)
            {
                x += Math.Sqrt(x);
            }
            sw.Stop();
            _logger.LogInformation("[guinea-pig.highcpu] - execution took {ElapsedMilliseconds} ms", sw.ElapsedMilliseconds);
            return Ok();
        }
        
        [HttpGet("highmemory")]
        public IActionResult HighMemory()
        {
            var sw = Stopwatch.StartNew();
            var numberOfBytes = 1073741824;
            Marshal.AllocHGlobal(numberOfBytes);
            sw.Stop();
            _logger.LogInformation("[guinea-pig.highmemory] - execution took {ElapsedMilliseconds} ms", sw.ElapsedMilliseconds);
            return Ok("highmemory");
        }

    }
}
