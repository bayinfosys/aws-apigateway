#!/bin/bash

##
#
# add-user to a cogntio user pool
#
# NB: this confirms the user in the pool
#
# params:
#    $1: cognito pool id
#    $2: cognito pool application id
#    $3: username
#    $4: password
#
#
# example:
#
#  for i in {10..25}
#  do
#    ./add-user.sh $POOL_ID $CLIENT_ID test-user-${i} test-password-${i}
#  done
#
##

#
# create a test user
#
aws cognito-idp sign-up \
  --client-id $2 \
  --username $3 \
  --password $4
#  --user-attributes=Name=email,Value=${each.value["email"]}

# set the password permanently so there is no challenge request to update password on first login
# this step also confirms the user
aws cognito-idp admin-set-user-password \
  --user-pool-id $1 \
  --username $3 \
  --password $4 \
  --permanent
