#!/usr/bin/env bash
# Test services running on durango.
source ./check_ssl_auth.sh
HOST=$1
run_query http://$HOST.durango.ctools.org/service/test/protected
run_query http://$HOST.durango.ctools.org/service/test/unprotected
#end
