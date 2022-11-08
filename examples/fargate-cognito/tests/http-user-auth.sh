#!/bin/bash -u

##
#
# get a token from cognito for a given user in a userpool
#
# params:
#    $1: application client name
#    $2: client application id
#    $3: username
#    $4: password
#
#
# https://cognito-idp.<aws-region>.amazonaws.com/<pool-id>/.well-known/openid-configuration
# https://cognito-idp.<aws-region>.amazonaws.com/<pool-id>/.well-known/jwks.json
#
##

AWS_REGION=eu-west-2

curl -v \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d client_id=$2 \
  -d grant_type=authorization_code \
  --data-urlencode redirect_uri=http://localhost:8000 \
  https://$1.auth.${AWS_REGION}.amazoncognito.com/token
