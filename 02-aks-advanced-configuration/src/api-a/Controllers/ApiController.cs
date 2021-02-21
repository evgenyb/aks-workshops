using api_a.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Linq;
using System.Threading.Tasks;

namespace api_a.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ApiController : ControllerBase
    {
        private readonly ILogger<ApiController> _logger;
        private readonly ICosmosDbService _cosmosDbService;

        public ApiController(ICosmosDbService cosmosDbService, ILogger<ApiController> logger)
        {
            _cosmosDbService = cosmosDbService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var item = new Item
            {
                Id = System.Guid.NewGuid().ToString(),
                Name = "Foobar"
            };
            await _cosmosDbService.AddItemAsync(item);

            var items = await _cosmosDbService.GetItemsAsync("SELECT * FROM c");
            _logger.LogInformation($"Received {items.Count()} items.");
            return Ok($"[api-a] - there are {items.Count()} items received.");
        }
    }
}
