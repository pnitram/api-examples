using System;
using System.Diagnostics;
using System.Net.Http;
using System.Threading.Tasks;
using IdentityModel.Client;
using Newtonsoft.Json;

namespace SampleApplication
{
    class Program
    {
        static void Main(string[] args)
        {
            RunAsync().Wait();
        }

        static async Task RunAsync()
        {
            /* 
            Client credentials and customerId

            Here Oauth2 is being used with "client credentials": The "client" is the application, and we require a secret 
            known only to the application.

             */

            var clientId = "******************************";
            var secret = "******************************";
            var customerId = "*****************";

            /** Setup constants */
            var discoveryEndpoint = "https://auth.sbanken.no/identityserver";
            var apiBaseAddress = "https://api.sbanken.no";
            var bankBasePath = "/exec.bank";
            var customersBasePath = "/exec.customers";

            /**
             * Connect to Sbanken
             *
             * Here the application connect to the identity server endpoint to retrieve a access token.
             */

            // First: get the OpenId configuration from Sbanken.
            var discoClient = new DiscoveryClient(discoveryEndpoint);

            var x = discoClient.Policy = new DiscoveryPolicy()
            {
                ValidateIssuerName = false,
            };

            var discoResult = await discoClient.GetAsync();

            if (discoResult.Error != null)
            {
                throw new Exception(discoResult.Error);
            }

            // The application now knows how to talk to the token endpoint.

            // Second: the application authenticates against the token endpoint
            var tokenClient = new TokenClient(discoResult.TokenEndpoint, clientId, secret);

            var tokenResponse = tokenClient.RequestClientCredentialsAsync().Result;

            if (tokenResponse.IsError)
            {
                throw new Exception(tokenResponse.ErrorDescription);
            }

            // The application now has an access token.

            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri(apiBaseAddress),
                DefaultRequestHeaders =
                {
                    { "customerId", customerId }
                }
            };

            // Finally: Set the access token on the connecting client. 
            // It will be used with all requests against the API endpoints.
            httpClient.SetBearerToken(tokenResponse.AccessToken);

            // The application retrieves the customer's information.
            var customerResponse = await httpClient.GetAsync($"{customersBasePath}/api/v1/Customers");
            var customerResult = await customerResponse.Content.ReadAsStringAsync();

            Trace.WriteLine($"CustomerResult:{customerResult}");

            // The application retrieves the customer's accounts.
            var accountResponse = await httpClient.GetAsync($"{bankBasePath}/api/v1/Accounts");
            var accountResult = await accountResponse.Content.ReadAsStringAsync();
            var accountsList = JsonConvert.DeserializeObject<AccountsList>(accountResult);

            Trace.WriteLine($"AccountResult:{accountResult}");

            var spesificAccountResponse = await httpClient.GetAsync($"{bankBasePath}/api/v1/Accounts/{accountsList.Items[0].AccountId}");
            var spesificAccountResult = await spesificAccountResponse.Content.ReadAsStringAsync();


            Trace.WriteLine($"SpesificAccountResult:{spesificAccountResult}");

        }
    }
}


