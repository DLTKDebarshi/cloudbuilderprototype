using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace CloudBuilderHelloWorld.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            ViewData["Message"] = "Hello World from Cloud Builder Prototype!";
            ViewData["Environment"] = Environment.MachineName;
            ViewData["DateTime"] = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            ViewData["Version"] = "1.0.0";
            return View();
        }

        public IActionResult About()
        {
            ViewData["Message"] = "Cloud Builder Prototype - Infrastructure as Code Demo";
            return View();
        }

        public IActionResult Health()
        {
            return Json(new { 
                status = "healthy", 
                timestamp = DateTime.UtcNow,
                server = Environment.MachineName,
                version = "1.0.0"
            });
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View();
        }
    }
}