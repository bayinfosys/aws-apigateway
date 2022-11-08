#!/bin/bash -u


##
#
# list pools accessible by this account
#
##

aws cognito-idp list-user-pools --max-results 60
