#!/bin/bash
# Setup Jenkins Project
if [ "$#" -ne 3 ]; then
    echo "Usage:"
    echo "  $0 GUID REPO CLUSTER"
    echo "  Example: $0 wkha https://github.com/wkulhanek/ParksMap na39.openshift.opentlc.com"
    exit 1
fi

GUID=$1
REPO=$2
CLUSTER=$3
echo "Setting up Jenkins in project ${GUID}-jenkins from Git Repo ${REPO} for Cluster ${CLUSTER}"

# Code to set up the Jenkins project to execute the
# three pipelines.
# This will need to also build the custom Maven Slave Pod
# Image to be used in the pipelines.
# Finally the script needs to create three OpenShift Build
# Configurations in the Jenkins Project to build the
# three micro services. Expected name of the build configs:
# * mlbparks-pipeline
# * nationalparks-pipeline
# * parksmap-pipeline
# The build configurations need to have two environment variables to be passed to the Pipeline:
# * GUID: the GUID used in all the projects
# * CLUSTER: the base url of the cluster used (e.g. na39.openshift.opentlc.com)

# To be Implemented by Student
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi --param DISABLE_ADMINISTRATIVE_MONITORS=true
oc new-build --name=jenkins-slave-appdev --dockerfile=$'FROM docker.io/openshift/jenkins-slave-maven-centos7:v3.9\nUSER root\nRUN yum -y install skopeo apb && \nyum clean all\nUSER 1001'
oc new-app --template=jboss-eap70-openshift:1.7 --param APPLICATION_NAME=mlbparks --param SOURCE_REPOSITORY_URL=https://github.com/SammZhu/advdev_homework.git --param SOURCE_REPOSITORY_REF=master --param CONTEXT_DIR=/MLBParks --param MAVEN_MIRROR_URL=http://nexus3-${GUID}-nexus.apps.${CLUSTER}/repository/maven-all-public
oc new-app --template=redhat-openjdk18-openshift:1.2 --param APPLICATION_NAME=nationalparks --param SOURCE_REPOSITORY_URL=https://github.com/SammZhu/advdev_homework.git --param SOURCE_REPOSITORY_REF=master --param CONTEXT_DIR=/Nationalparks --param MAVEN_MIRROR_URL=http://nexus3-${GUID}-nexus.apps.${CLUSTER}/repository/maven-all-public
oc new-app --template=redhat-openjdk18-openshift:1.2 --param APPLICATION_NAME=parksmap --param SOURCE_REPOSITORY_URL=https://github.com/SammZhu/advdev_homework.git --param SOURCE_REPOSITORY_REF=master --param CONTEXT_DIR=/ParksMap --param MAVEN_MIRROR_URL=http://nexus3-${GUID}-nexus.apps.${CLUSTER}/repository/maven-all-public
oc new-app -f ../templates/pipeline.yaml -p GUID=${GUID},CLUSTER=${CLUSTER}
