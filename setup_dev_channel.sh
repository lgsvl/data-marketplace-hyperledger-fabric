#!/bin/bash

if [ -d "${PWD}/configFiles" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Configuration files are not found."
    exit
fi


# Generate channel artifacts using configtx.yaml and then create channel
echo -e "\nCreating channel transaction artifact and a channel"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/create_channel.yaml -n dev"
kubectl create -f ${KUBECONFIG_FOLDER}/create_channel.yaml -n dev

JOBSTATUS=$(kubectl get jobs -n dev |grep createchannel |awk '{print $3}')
while [ "${JOBSTATUS}" != "1" ]; do
    echo "Waiting for createchannel job to be completed"
    sleep 1;
    if [ "$(kubectl get pods -n dev | grep createchannel | awk '{print $3}')" == "Error" ]; then
        echo "Create Channel Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs -n dev |grep createchannel |awk '{print $3}')
done
echo "Create Channel Completed Successfully"


# Join all peers on a channel
echo -e "\nCreating joinchannel job"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/join_channel.yaml -n dev"
kubectl create -f ${KUBECONFIG_FOLDER}/join_channel.yaml -n dev

JOBSTATUS=$(kubectl get jobs -n dev |grep joinchannel |awk '{print $3}')
while [ "${JOBSTATUS}" != "1" ]; do
    echo "Waiting for joinchannel job to be completed"
    sleep 1;
    if [ "$(kubectl get pods -n dev | grep joinchannel | awk '{print $3}')" == "Error" ]; then
        echo "Join Channel Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs -n dev |grep joinchannel |awk '{print $3}')
done
echo "Join Channel Completed Successfully"

sleep 15
echo -e "\nNetwork Setup Completed !!"


# Delete existing copyartifacts createchannel  joinchannel
echo -e "\deleting  copyartifacts createchannel  joinchannel jobs."
echo "Running: kubectl delete jobs -n dev copyartifacts createchannel  joinchannel "
kubectl delete jobs -n dev copyartifacts createchannel  joinchannel