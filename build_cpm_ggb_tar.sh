#!/usr/bin/env bash

### Generate a zip file that contains both wars required for a CPM tomcat deployment.
### This is checked in here so that it has a home.  It is expected to be used in Jenkins builds.
### The script should be run as the build.sh for the jenkins job CPM_bundled_war_files_most_recent
### TTD:
### - don't add internal web-server.

JENKINS_CPM=http://limpkin.dsc.umich.edu:6660/view/CTools_Project_Migration/job
MFILE=VERSION.Makefile

########### get the microservice

#set -x
set -u

function msg {
    txt="$@"
    echo ">>>> $txt"
}

function get_microservice {
    msg "get ggb microservice war file"
    # get version makefile
    wget $JENKINS_CPM/GGB_MICROSERVICE/lastSuccessfulBuild/artifact/ARTIFACTS/$MFILE -O - | grep -iv 'args'  >| GGB.$MFILE
    # now get the war file
    source ./GGB.$MFILE
    GGB_BUILD=${BUILD}
    echo "GGB: using build $GGB_BUILD from $ARTIFACTFILE"
    wget -q -N ${ARTIFACTFILE}
    rm GGB.$MFILE
}

function get_cpm_app {
    msg "get cpm war file build:"
#    CTools_Project_Migration
    wget $JENKINS_CPM/CTools_Project_Migration/lastSuccessfulBuild/artifact/$MFILE -O - | grep -iv 'args'  >| CPM.$MFILE
    # now get the war file
    source ./CPM.$MFILE
    CPM_BUILD=${BUILD}
    echo "CPM: using build $CPM_BUILD from $ARTIFACTFILE"
    wget -q -N ${ARTIFACTFILE}
    rm CPM.$MFILE
}


function generate_zip {
    msg "generate combined war tar file"
    [ -d ./tmp ] && rm -rf ./tmp
    mkdir tmp
    cp ctools-project*war tmp/ROOT.war
    cp ggb*war tmp/service.war
    tar -cf cpm.${CPM_BUILD}.ggb.${GGB_BUILD}.tar -C tmp service.war ROOT.war
    echo "files in tar"
    tar -tvf *tar
    rm -rf tmp
}


get_microservice

get_cpm_app

generate_zip

function writeEnvironmentVariables {
    local TIMESTAMP_value="XXXXX"
    local CPM_BUILD=$(ls cpm.*.ggb.*tar | perl -n -e 'm/cpm\.(.+)\.ggb\.(.+)\.tar/ && print $1' )
    local GGB_BUILD=$(ls cpm.*.ggb.*tar | perl -n -e 'm/cpm\.(.+)\.ggb\.(.+)\.tar/ && print $2' )
    local TAR_NAME_value=cpm.${CPM_BUILD}.ggb.${GGB_BUILD}
    vars=`cat <<EOF
########################
# Environment variables for installation of this build.
WEBRELSRC=http://limpkin.dsc.umich.edu:6660/job/
JOBNAME=${JOB_NAME:-LOCAL}
BUILD=${BUILD_NUMBER:-imaginary}
ARTIFACT_DIRECTORY=artifact
IMAGE_INSTALL_TYPE=tar
IMAGE_NAME=${TAR_NAME_value}.tar
CONFIGURATION_NAME=configuration-files.${TIMESTAMP_value}.tar
#######################
ARTIFACTFILE=\\\${WEBRELSRC}/\\\${JOBNAME}/\\\${BUILD}/\\\${ARTIFACT_DIRECTORY}/\\\${IMAGE_NAME}
CONFIGFILE=\\\${WEBRELSRC}/\\\${JOBNAME}/\\\${BUILD}/\\\${ARTIFACT_DIRECTORY}/\\\${CONFIGURATION_NAME}
#######################
EOF`
    echo "${vars}"
}

# put copy in build
writeEnvironmentVariables >| VERSION.Makefile
# put copy in console output
writeEnvironmentVariables

#end


