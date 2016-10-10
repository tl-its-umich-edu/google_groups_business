#!/usr/bin/env bash
# Test services running on durango.
source ./check_ssl_auth.sh
HOST=http://ms-ggb-dev-cpm-dev.openshift.dsc.umich.edu
BASE=${HOST}

run_query $BASE/test/protected
run_query $BASE/test/unprotected
run_query $BASE/status.json
#end
