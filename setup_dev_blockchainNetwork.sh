#!/bin/bash

if [ -d "${PWD}/configFiles" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Configuration files are not found."
    exit
fi

# Copy the required files(configtx.yaml, cruypto-config.yaml, sample chaincode etc.) into volume
echo -e "\nCreating Copy artifacts job."
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml -n dev"
kubectl create -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml -n dev

pod=$(kubectl get pods -n dev --selector=job-name=copyartifacts --output=jsonpath={.items..metadata.name})

podSTATUS=$(kubectl get pods -n dev --selector=job-name=copyartifacts --output=jsonpath={.items..phase})

while [ "${podSTATUS}" != "Running" ]; do
    echo "Wating for container of copy artifact pod to run. Current status of ${pod} is ${podSTATUS}"
    sleep 5;
    if [ "${podSTATUS}" == "Error" ]; then
        echo "There is an error in copyartifacts job. Please check logs."
        exit 1
    fi
    podSTATUS=$(kubectl get pods  -n dev --selector=job-name=copyartifacts --output=jsonpath={.items..phase})
done

echo -e "${pod} is now ${podSTATUS}"
echo -e "\nStarting to copy artifacts in persistent volume."

#fix for this script to work on icp and ICS
kubectl cp ./artifacts $pod:/shared/ -n dev

echo "Waiting for 10 more seconds for copying artifacts to avoid any network delay"
sleep 20
# JOBSTATUS=$(kubectl get jobs -n dev |grep "copyartifacts" |awk '{print $3}')
# while [ "${JOBSTATUS}" != "1" ]; do
#     echo "Waiting for copyartifacts job to complete"
#     sleep 1;
#     PODSTATUS=$(kubectl get pods -n dev | grep "copyartifacts" | awk '{print $3}')
#         if [ "${PODSTATUS}" == "Error" ]; then
#             echo "There is an error in copyartifacts job. Please check logs."
#             exit 1
#         fi
#     JOBSTATUS=$(kubectl get jobs -n dev |grep "copyartifacts" |awk '{print $3}')
# done
# echo "Copy artifacts job completed"
#

# Generate Network artifacts using configtx.yaml and crypto-config.yaml
echo -e "\nGenerating the required artifacts for Blockchain network"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/generateArtifactsJob.yaml -n dev"
kubectl create -f ${KUBECONFIG_FOLDER}/generateArtifactsJob.yaml -n dev

JOBSTATUS=$(kubectl get jobs -n dev|grep utils|awk '{print $3}')
while [ "${JOBSTATUS}" != "1" ]; do
    echo "Waiting for generateArtifacts job to complete"
    sleep 1;
    # UTILSLEFT=$(kubectl get pods | grep utils | awk '{print $2}')
    UTILSSTATUS=$(kubectl get pods -n dev | grep "utils" | awk '{print $3}')
    if [ "${UTILSSTATUS}" == "Error" ]; then
            echo "There is an error in utils job. Please check logs."
            exit 1
    fi
    # UTILSLEFT=$(kubectl get pods | grep utils | awk '{print $2}')
    JOBSTATUS=$(kubectl get jobs -n dev |grep utils|awk '{print $3}')
done


# # Create services for all peers, ca, orderer
# echo -e "\nCreating Services for blockchain network"
# echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml -n dev"
# kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml -n dev





# Create peers, ca, orderer using Kubernetes Deployments
echo -e "\nCreating new Deployment to create four peers in network"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/peersDeployment.yaml -n dev"
kubectl create -f ${KUBECONFIG_FOLDER}/peersDeployment.yaml -n dev

echo "Checking if all deployments are ready"

NUMPENDING=$(kubectl get deployments -n dev | grep blockchain | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments -n dev | grep blockchain | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
    sleep 1
done

echo "Waiting for 15 seconds for peers and orderer to settle"
sleep 15

# Delete existing copychaincode, chaincodeupgrade, chaincodeinstall and chaincodeinstantiate
echo -e "\deleting  jobs."
echo "Running: kubectl delete jobs -n dev utils copyartifacts -n dev "
kubectl delete jobs -n dev utils copyartifacts -n dev 
