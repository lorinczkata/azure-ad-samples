using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.Services.AppAuthentication;
using System.Net.Http;
using System.Net.Http.Headers;

namespace Test.Function
{
    public static class CallWebApi
    {
        [FunctionName("CallWebApi")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            var webApiUrl = Environment.GetEnvironmentVariable("WEB_API_URL");

            log.LogInformation("C# HTTP trigger function processed a request.");

            try
            {

                using (var client = new HttpClient())
                {
                    var token = await GetToken(log);
                    
                    client.DefaultRequestHeaders.Authorization = 
                            new AuthenticationHeaderValue("Bearer", token);
                    
                    var url = $"{webApiUrl}/weatherforecast";
                    var res = await client.GetAsync(url);
                    var body = await res.Content.ReadAsStringAsync();
                    return new OkObjectResult(body);
                }
            }
            catch (Exception ex)
            {
                log.LogError(ex.Message);
            }

            return new OkResult();


        }

        private static async Task<string> GetToken(ILogger log)
        {
            try
            {
                string webPortalResource = Environment.GetEnvironmentVariable("WEB_API_AD_APP_ID_URI");
                var azServiceTokenProvider = new AzureServiceTokenProvider();
                var token = await azServiceTokenProvider.GetAccessTokenAsync(webPortalResource);
                log.LogInformation($"token: {token}");
                return token;
            }
            catch (Exception ex)
            {
                log.LogWarning(ex.Message);
                return $"{nameof(GetToken)} failed";
            }
        }
    }
}
