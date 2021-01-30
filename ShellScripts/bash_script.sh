#!/bin/bash

# this script requires `jq` to be installed in order to read json objects.
# apt-get install jq
# - or -
# dnf install jq

# setup
#
# remember to urlencode clientId and secret
clientId='*******************'
secret='******************************'
userId='***********'

# Url encode
urlencode() {
  string=$1; format=; set --
  while [ -n "$string" ]; do
    tail=${string#?}
    head=${string%$tail}
    case $head in
      [-._~0-9A-Za-z]) format=$format%c; set -- "$@" "$head";;
      *) format=$format%%%02x; set -- "$@" "'$head";;
    esac
    string=$tail
  done
  printf "$format\\n" "$@"
}

encodedData1=$(urlencode $clientId)
encodedData2=$(urlencode $secret)


# headers
acceptHeader='Accept: application/json'
contentTypeHeader='Content-Type: application/x-www-form-urlencoded; charset=utf-8'

# request body
requestBody='grant_type=client_credentials'

token=$(curl -q -u "$clientId:$secret" -H "$acceptHeader" -H "$contentTypeHeader" -d "$requestBody" 'https://auth.sbanken.no/IdentityServer/connect/token' 2>/dev/null| jq -r .access_token)

accounts=$(curl -q -H "customerId: $userId" -H "Authorization: Bearer $token" "https://api.sbanken.no/exec.bank/api/v1/Accounts"  2>/dev/null)
matches=$(echo $accounts|jq -r .availableItems)

for i in $(seq 0 $(($matches - 1)))
do
    accountNumber=$(echo $accounts | jq -r ".items[$i].accountNumber")
    balance=$(echo $accounts | jq -r ".items[$i].balance")
    available=$(echo $accounts | jq -r ".items[$i].available")
    name=$(echo $accounts | jq -r ".items[$i].name")
    printf "%-20s\t%-11s\t%8.2f\t%8.2f\n" "$name" "$accountNumber" $balance $available
done
