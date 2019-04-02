#!/bin/bash

if [ -d "${PWD}/configFiles" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Configuration files are not found."
    exit
fi

# Creating Persistant Volume
echo -e "\nCreating volume"
if [ "$(kubectl get pvc -n hyperledger | grep shared-pvc | awk '{print $2}')" != "Bound" ]; then
    echo "The Persistant Volume does not seem to exist or is not bound"
    echo "Creating Persistant Volume"


    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/createVolume.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/createVolume.yaml -n hyperledger
    sleep 5
 

    if [ "kubectl get pvc -n hyperledger | grep shared-pvc | awk '{print $3}'" != "shared-pv" ]; then
        echo "Success creating Persistant Volume"
    else
        echo "Failed to create Persistant Volume"
    fi
else
    echo "The Persistant Volume exists, not creating again"
fi


# Creating Persistant Volume for couchDB
echo -e "\nCreating volumes for couchDB"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/createCouchDBVolume.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/createCouchDBVolume.yaml -n hyperledger
sleep 5
