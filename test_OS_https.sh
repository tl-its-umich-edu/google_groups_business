#!/usr/bin/env bash
# Test services running on durango.
source ./check_ssl_auth.sh

IGNORE_SSL_CERTIFICATES=1

HOST=https://ggb.openshift.dsc.umich.edu
BASE=${HOST}

run_query $BASE/test/protected
run_query $BASE/test/unprotected
run_query $BASE/status.json
#end
