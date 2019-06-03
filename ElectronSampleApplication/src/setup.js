


export default function setup()  {
   
  const config = {       
    identityServerUrl : "https://auth.sbanken.no/identityserver/connect/token",
    accountServiceUrl : "https://api.sbanken.no/exec.bank/api/v1/accounts",
    clientId : "************************",
    secret : "************************",
    customerId : "************",
  };

  return config;
}
