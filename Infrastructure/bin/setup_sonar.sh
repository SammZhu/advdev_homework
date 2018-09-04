#!/bin/bash
# Setup Sonarqube Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Sonarqube in project $GUID-sonarqube"

# Code to set up the SonarQube project.
# Ideally just calls a template
# oc new-app -f ../templates/sonarqube.yaml --param .....

# To be Implemented by Student
oc process -f ./Infrastructure/templates/sonar.yaml \
    -n ${GUID}-sonarqube \
    | oc create -n ${GUID}-sonarqube -f -
# oc rollout latest dc/sonarqube
# oc create -f ./Infrastructure/templates/sonar.yaml -n ${GUID}-sonarqube
