#!/bin/bash

source config.cfg

if [ -z "$KEYSTORE_FILE" ] || [ -z "$KEYSTORE_PASSWORD" ] || [ -z "$ISSUER" ] || [ -z "$AUDIENCE" ] || [ -z "$SCOPE" ]; then
    echo "One or more required variables are not set in config.cfg"
    exit 1
fi

openssl pkcs12 -in "$KEYSTORE_FILE" -clcerts -nokeys -passin pass:"$KEYSTORE_PASSWORD" -out cert.pem
openssl pkcs12 -in "$KEYSTORE_FILE" -nocerts -nodes -passin pass:"$KEYSTORE_PASSWORD" -out key.pem

x5c=$(openssl x509 -in cert.pem -outform DER | openssl base64 -A)

header=$(echo -n "
    {
        \"alg\":\"RS256\",
        \"x5c\":[\"$x5c\"]
    }" | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Claims
iat=$(date -u +%s)
exp=$(($iat + 60))
jti=$(uuidgen)
payload=$(echo -n "
    {
        \"scope\":\"$SCOPE\",
        \"iss\":\"$ISSUER\",
        \"aud\":\"$AUDIENCE\",
        \"exp\":$exp,
        \"iat\":$iat,
        \"jti\":\"$jti\"
    }" | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

signature=$(echo -n "$header.$payload" | openssl dgst -sha256 -sign key.pem | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

jwt="$header.$payload.$signature"

echo "JWT: $jwt"

if [ -z "$jwt" ]; then
    echo "JWT creation failed"
    exit 1
fi

response=$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$jwt" "$TOKEN_ENDPOINT")
access_token=$(echo "$response" | jq -r '.access_token')

echo "Response: $response"
echo "Access token: $access_token"

rm cert.pem key.pem
