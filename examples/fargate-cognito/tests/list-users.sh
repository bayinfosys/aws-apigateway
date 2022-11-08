#!/bin/bash -u


##
#
# list users in a pool
#
#
# params:
#    $1: cognito user pool id
##

aws cognito-idp list-users --user-pool-id $1
