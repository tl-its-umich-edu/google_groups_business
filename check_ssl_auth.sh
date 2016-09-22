#!/usr/bin/env bash
# Run curl request against url specified or
# default url.  Will add basic auth header.

#set -x
# comment in/out to get verbose curl processing
#VERBOSE='-v'

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

# default auth info
# auth info
USER=admin.XXX
PW=admin

# create auth header  (Putting -H in string doesn't work.)
UP=$(echo -n "$USER:$PW" | base64)
AUTH_HEADER="Authorization: Basic $UP"

echo "test_url: [$test_url]"
# Assemble args in array to pass to command.
# Trying to build string version of command consider impossible in bash.
curl_args=($VERBOSE '-H' "$AUTH_HEADER" "$test_url")

#echo "curl_args: [""${curl_args[@]}""]"
curl "${curl_args[@]}"
echo ""
#end
