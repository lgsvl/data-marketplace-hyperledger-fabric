#!/bin/bash
if [ -d "${PWD}/configFiles" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Configuration files are not found."
    exit
fi

export VERSION=$1

# Copy the required files(configtx.yaml, cruypto-config.yaml, sample chaincode etc.) into volume
echo -e "\nCreating Copy artifacts job."
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/copyNewChaincode.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/copyNewChaincode.yaml

pod=$(kubectl get pods --selector=job-name=copychaincode --output=jsonpath={.items..metadata.name})

podSTATUS=$(kubectl get pods --selector=job-name=copychaincode --output=jsonpath={.items..phase})

while [ "${podSTATUS}" != "Running" ]; do
    echo "Wating for container of copy chaincode pod to run. Current status of ${pod} is ${podSTATUS}"
    sleep 5;
    if [ "${podSTATUS}" == "Error" ]; then
        echo "There is an error in copychaincode job. Please check logs."
        exit 1
    fi
    podSTATUS=$(kubectl get pods --selector=job-name=copychaincode --output=jsonpath={.items..phase})
done

echo -e "${pod} is now ${podSTATUS}"
echo -e "\nStarting to copy chaincode in persistent volume."

#fix for this script to work on icp and ICS
kubectl cp $GOPATH/src/pse-gitlab.lgsvl.net/data_marketplace/data-marketplace-chaincode $pod:/shared/artifacts/chaincode/data-marketplace-chaincode

echo "Waiting for 10 more seconds for copying artifacts to avoid any network delay"
sleep 20

# install chaincode on each peer
echo -e "\nCreating installchaincode job"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml"
envsubst '$VERSION' < ${KUBECONFIG_FOLDER}/chaincode_install.yaml | kubectl create -f -
JOBSTATUS=$(kubectl get jobs |grep chaincodeinstall |awk '{print $3}')
while [ "${JOBSTATUS}" != "1" ]; do
    echo "Waiting for chaincodeinstall job to be completed"
    sleep 1;
    if [ "$(kubectl get pods | grep chaincodeinstall | awk '{print $3}')" == "Error" ]; then
        echo "Chaincode Install Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs |grep chaincodeinstall |awk '{print $3}')
done
echo "Chaincode install Completed Successfully"


# upgrading chaincode on each peer
echo -e "\nCreating upgradechaincode job"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_upgrade.yaml"

envsubst '$VERSION' < ${KUBECONFIG_FOLDER}/chaincode_upgrade.yaml | kubectl create -f -
JOBSTATUS=$(kubectl get jobs |grep chaincodeupgrade |awk '{print $3}')
while [ "${JOBSTATUS}" != "1" ]; do
    echo "Waiting for chaincodeupgrade job to be completed"
    sleep 1;
    if [ "$(kubectl get pods | grep chaincodeupgrade | awk '{print $3}')" == "Error" ]; then
        echo "Chaincode Upgrade Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs |grep chaincodeupgrade |awk '{print $3}')
done
echo "Chaincode upgrade Completed Successfully"


# Delete existing copychaincode, chaincodeupgrade, chaincodeinstall and chaincodeinstantiate
echo -e "\deleting  copychaincode,chaincodeupgrade and chaincodeinstall jobs."
echo "Running: kubectl delete jobs copychaincode chaincodeupgrade  chaincodeinstall "
kubectl delete jobs copychaincode chaincodeupgrade chaincodeinstall  