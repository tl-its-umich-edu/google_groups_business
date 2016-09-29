#!/usr/bin/env bash
# Run curl request against url specified or
# default url.  Use curl basic auth so it can
# deal with initial rejection challange.

#set -x
# comment in/out to get verbose curl processing
#VERBOSE='-v'

#### get credentials  Properties file must set USER and PS environment variables.
source ./.check_auth.properties
echo "using user: ${USER}"
######

########
# Setup test url, default if not supplied on command line.
if [ -z "$1" ]; then
    echo "url value is NOT set"
    PROTO=http://
    SERVER=localhost:4567
    URL=/status
    test_url="${PROTO}${SERVER}${URL}"
else
    test_url=$1
fi
########

##### run query
echo "test_url: [$test_url]"
# Assemble args in array to pass to command.
# Trying to build string version of command considered impossible in bash.
curl_args=($VERBOSE --basic --user $USER:$PS "$test_url")

#echo "curl_args: [""${curl_args[@]}""]"
curl "${curl_args[@]}"
echo ""
#end
