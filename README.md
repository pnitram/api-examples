# API usage examples

## Introduction

This repository provides a few examples on how to use Sbankens Open Banking APIs. These will enable you to quickly get started and get familiar with the basic concepts of authorization and API usage.

### [DotNetCoreSampleApplication](./DotNetCoreSampleApplication/)
Simple .NET Core Console Application which retrieves accessToken, customer and account information.

### [NodeSampleApplication](./NodeSampleApplication/)
Simple Node client which retrieves accessToken and account information.

### [JavaSampleApplication](./JavaSampleApplication/)
Java client which retrieves accessToken and account information.

### [ElectronSampleApplication](./ElectronSampleApplication/)
Simple Electron App with an example GUI which retrieves accessToken and account information.

### [VueSampleApplication](./VueSampleApplication/)
Simple Vue.js App with an example GUI which retrieves account information and transactions.

### [PythonSampleApplication](./PythonSampleApplication/)
Python script which retrieves accessToken, customer and account information.

### [ShellScripts](./ShellScripts/)
Shell script examples on how to retrieve accessToken and account information.


## Documentation 

# Update June 2019
* Changed the example URLs to target /exec.bank instead of /bank

# Update November 2018
* Added documentation for [transactionTypes](./Documentation/) for the TransactionsAPI

# Update September 2018
* Changed authentication endpoint from https://api.sbanken.no/identityserver to https://auth.sbanken.no/identityserver


# Update May 2018

* We have stopped using customerId as a part of the API URL. Instead we require all API requests to include the customerId as a http header. See swagger for more information.
* We have rolled back all APIs to start on V1
* We have stopped using AccountNumber as part of the URL. Instead we require all Account API requests to include the AccountId as retrieved from HTTP GET /exec.bank/api/v1/Accounts (see powershell script example)
* Update of IdentityServer requires Clients to form-urlencode ClientId and Secret prior to Base64-encoding the Authorization header. This is according to specification in RFC6749. See [DotNetCoreSampleApplication](./DotNetCoreSampleApplication/) (updated to IdentityModel 3.6.1 which does this automatically) and [ShellScripts](./ShellScripts/) example.

### Swagger

The following links provides detailed description of the REST interfaces. This includes how to construct your requests and what response to expect.


https://api.sbanken.no/Bank/swagger

https://api.sbanken.no/Customers/swagger

### Authentication

#### How to get an Access Token

One must authenticate in order to get an access token. To authenticate the clientId and secret is sent to the sbanken authorization server. If valid, an access token is returned. 

```
// client credentials

var clientId = "*****" // clientId obtained from Sbanken API Beta / utviklerportalen
var secret = "****" // password

// First, the application must authenticate itself with Sbanken's authorization server.
// The basic authentication scheme is used here (https://tools.ietf.org/html/rfc2617#section-2 ) 

// The clientId and secret must first be urlencoded and then base64 encoded, separated by a single colon ( : ).
// You might have to investigate which base64 encoding-library to use depending on your choice of programming language.

var basicAuthentationHeaderValue = btoa(encodeURIComponent(clientId) + ":" + encodeURIComponent(secret));
```

To obtain the access token, send a request to the token URI with the following http headers. 
Note: For the Authorization header, the value of the header must be prefixed with  "Basic " as shown below.

```
// host
https://auth.sbanken.no

// uri
POST /identityserver/connect/token  

// headers
Authorization: Basic Y2xpZW50aWQ6c2VjcmV0
Accept: application/json  
Content-Type: application/x-www-form-urlencoded

// request body
grant_type=client_credentials  
```

If the request was successful, one should get the following response:

```
{
    "access_token": "abcdefghijklmnopqrstuvwxyz..",
    "expires_in": 3600,
    "token_type": "Bearer"
}
```



## Known bugs

### Swagger documentation

* The Try Me-button will not work. This is because it will send an unauthenticated request.
* Transactions: TransactionId is returned in Transactions although not part of documentation.
* Transactions: source will either be 0 or 1 although documentation states it should be an enum string (accountStatement or archive)

## FAQ

### How do I find the customerId / userId?

This is your social security number. The same Id which is used when you log in with BankID.


## Availability

In order to get access to these APIs certain requirements needs to be fullfilled:
* You are a Sbanken customer
* You have to sign up for access via https://utvikler.sbanken.no
* You have to enable "Beta" in your personal settings
* Finally, you need to complete the API Beta setup wizard.

(Detailed information will be provided after you sign up for access)
