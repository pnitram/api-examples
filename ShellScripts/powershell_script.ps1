
# -- SETUP --
$userid= "***********"
$clientId = "**********************"
$secret = "*******"
# -- END SETUP --

$headers = @{}
$encodedClientId = [System.Web.HttpUtility]::UrlEncode($clientId) 
$encodedSecret = [System.Web.HttpUtility]::UrlEncode($secret) 

$credentials = "$($encodedClientId):$($encodedSecret)"

$Bytes = [System.Text.Encoding]::UTF8.GetBytes($credentials)
$EncodedText =[Convert]::ToBase64String($Bytes)

$headers.Add("Authorization", "Basic "+$EncodedText)
$headers.Add("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
$headers.Add("Accept", "application/json")
$postParams = @{grant_type='client_credentials'}
$authResponse = Invoke-RestMethod -Uri "https://auth.sbanken.no/IdentityServer/connect/token" -Method POST -Headers $headers -Body $postParams

echo "Accounts ----"
$authHeaders = @{}
$authHeaders.Add("Accept", "application/json")
$authHeaders.Add("customerId", $userid);
$authHeaders.Add("Authorization", "Bearer "+$authResponse.access_token)
$accountUri = "https://api.sbanken.no/exec.bank/api/v1/Accounts"
$response = Invoke-RestMethod -Uri $accountUri -Method GET -Headers $authHeaders
$response


echo "Get spesific account based on AccountId"
$authHeaders = @{}
$authHeaders.Add("Accept", "application/json")
$authHeaders.Add("customerId", $userid);
$authHeaders.Add("Authorization", "Bearer "+$authResponse.access_token)
$accountUri = "https://api.sbanken.no/exec.bank/api/v1/Accounts/" +  $response.items[0].accountId
$response = Invoke-RestMethod -Uri $accountUri -Method GET -Headers $authHeaders
$response



