#!/usr/bin/env bash
# Run curl request against url specified or

# default url.  Use curl basic auth so it can
# deal with initial rejection challange.
# check IGNORE_SSL_CERTIFICATES to see if should add -k

#set -x
# comment in/out to get verbose curl processing
#VERBOSE='-v'

#### get credentials  Properties file must set USER and PS environment variables.
source ./.check_auth.properties
echo "+++ user: ${USER}"
######


########

##### run query
function run_query {
    local request=$1
    #    echo "test_url: [$test_url]"
    echo "+++ request: [$request]"
    IGNORE_SSL=
    if [ ! -z "$IGNORE_SSL_CERTIFICATES" ]; then
        echo "---- IGNORING SSL_CERTIFICATES"
        IGNORE_SSL=" -k "
    fi
    # Assemble args in array to pass to command.
    # Trying to build string version of command considered impossible in bash.
    curl_args=($VERBOSE $IGNORE_SSL --basic --user $USER:$PS "$request")

 #    echo "+++ curl_args: [""${curl_args[@]}""]"
    curl "${curl_args[@]}"
    echo ""
}

########
# If url is supplied then ask query, otherwise just
# setup so, when included in another script, allows
# running queries.

# if [ ! -z "$1" ]; then
#     test_url=$1
#     run_query $test_url
# fi

#end
