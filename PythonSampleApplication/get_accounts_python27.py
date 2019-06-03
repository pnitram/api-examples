import requests
import urllib
import base64
import pprint

# This example requires the requests library.
# It can usually be installed by running
# pip install requests


CLIENT_ID = ''  # Get from https://secure.sbanken.no/Personal/ApiBeta/Info/
SECRET = ''  # Get this from https://secure.sbanken.no/Personal/ApiBeta/Info/
AUTH_URL = 'https://auth.sbanken.no/identityserver/connect/token'
ACCOUNTS_URL = 'https://api.sbanken.no/exec.bank/api/v1/accounts'
CUSTOMER_ID = ''  # Your own personnummer


def get_auth_token(auth_url, client_id, secret):
    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
    }
    body = {'grant_type': 'client_credentials'}

    urlencoded_client_id = urllib.quote(client_id)
    urlencoded_secret = urllib.quote(secret)
    auth_string_to_be_b64encoded = '{}:{}'.format(
        urlencoded_client_id, urlencoded_secret)
    b64encoded_auth_string = base64.b64encode(auth_string_to_be_b64encoded)
    headers['Authorization'] = 'Basic {}'.format(b64encoded_auth_string)

    r = requests.post(url=auth_url, headers=headers, data=body)
    auth_token = r.json()['access_token']
    return auth_token
    
def get_accounts(accounts_url, auth_token, customer_id):
    headers = {
        'customerId': customer_id,
        'Authorization': 'Bearer {}'.format(auth_token)
    }

    r = requests.get(
        url=accounts_url, headers=headers)
    return r

if __name__ == "__main__":
    auth_token = get_auth_token(AUTH_URL, CLIENT_ID, SECRET)
    accounts = get_accounts(ACCOUNTS_URL, auth_token, CUSTOMER_ID)
    pprint.pprint(accounts.json())
