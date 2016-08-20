#!/bin/bash

CPM_BUILD=151
GGB_WAR_NAME=service
GGB_BUILD=XXX

JENKINS_CPM=http://limpkin.dsc.umich.edu:6660/view/CTools_Project_Migration/job
MFILE=VERSION.Makefile
TOMCAT=/usr/local/ctools/user/dlhaines/ws/google_groups_business/TOMCAT/apache-tomcat

# will need to have the oracle jdbc jar installed in tomcat.  e.g.
#cp /usr/local/ctools/user/dlhaines/ws/sakai-2.9.x/TOMCAT/common/lib/home/dlhaines/resources/lib/ojdbc6.jar $TOMCATg/lib

########### get the microservice

#set -x
set -u

function msg {
    txt="$@"
    echo ">>>> $txt"
}

function get_microservice {
    msg "get ggb microservice war file"
    ####### GGB
    # get version makefile 
    wget $JENKINS_CPM/GGB_MICROSERVICE/lastSuccessfulBuild/artifact/ARTIFACTS/$MFILE -O - | grep -iv 'args'  >| GGB.$MFILE
    # now get the war file
    source ./GGB.$MFILE
    #echo "war file: ${ARTIFACTFILE}"
    #echo "ggb build: ${BUILD}"
    GGB_BUILD=${BUILD}
    wget -N ${ARTIFACTFILE}

}

function get_cpm_app {
    msg "get cpm war file build: $CPM_BUILD"
    ######### get the cpm war
    # need to specify the exact build since don't have VERSION.Makefile in the build.
    curl -O $JENKINS_CPM/CTools_Project_Migration/lastSuccessfulBuild/artifact/artifact/ctools-project-migration.${CPM_BUILD}.war
}

function install_wars {
    # install the wars
    msg "install wars to tomcat"
    local TOMCAT=$1

    if ! [ -e $TOMCAT ]; then
        echo "exiting: no such tomcat directory. $TOMCAT"
        exit 1;
    fi
    
    rm -rf $TOMCAT/webapps/ROOT*
    rm -rf $TOMCAT/webapps/${GGB_WAR_NAME}*

    cp ctools-project*war $TOMCAT/webapps/ROOT.war
    cp GGB*war $TOMCAT/webapps/${GGB_WAR_NAME}.war
}

function generate_zip {
#    set -x
    msg "generate combined war tar file"
    [ -d ./tmp ] && rm -rf ./tmp
    mkdir tmp
    cp ctools-project*war tmp/ROOT.war
    cp GGB*war tmp/service.war
    tar -cf cpm.${CPM_BUILD}.ggb.${GGB_BUILD}.tar -C tmp service.war ROOT.war
    echo "files in tar"
    tar -tvf *tar
    rm -rf tmp
}

get_microservice

get_cpm_app

echo "LIST files:"
ls -l

generate_zip

#install_wars $TOMCAT
#tar -cf cpm.A.B.zip *war
#end


