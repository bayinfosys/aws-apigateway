#!/bin/bash -u

##
#
# create an application for a user pool
#
# params:
#    $1: cognito user pool id
#    $2: client application name
#
##

aws cognito-idp \
  create-user-pool-client \
    --user-pool-id $1 \
    --client-name $2 \
    --callback-urls 'http://localhost:8000'

aws cognito-idp \
  create-user-pool-domain \
    --domain $2 \
    --user-pool-id $1
