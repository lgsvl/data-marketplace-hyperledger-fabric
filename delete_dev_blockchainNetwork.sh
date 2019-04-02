
KUBECONFIG_FOLDER=${PWD}/configFiles

kubectl delete -f ${KUBECONFIG_FOLDER}/chaincode_instantiate.yaml -n dev
kubectl delete -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml -n dev

kubectl delete -f ${KUBECONFIG_FOLDER}/join_channel.yaml -n dev
kubectl delete -f ${KUBECONFIG_FOLDER}/create_channel.yaml -n dev

kubectl delete -f ${KUBECONFIG_FOLDER}/peersDeployment.yaml -n dev
# kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml

kubectl delete -f ${KUBECONFIG_FOLDER}/generateArtifactsJob.yaml -n dev
kubectl delete -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml -n dev


sleep 10

echo -e "\npv:" 
kubectl get pv -n dev
echo -e "\npvc:"
kubectl get pvc -n dev
echo -e "\njobs:"
kubectl get jobs  -n dev
echo -e "\ndeployments:"
kubectl get deployments -n dev
echo -e "\nservices:"
kubectl get services -n dev
echo -e "\npods:"
kubectl get pods -n dev

echo -e "\nNetwork Deleted!!\n"

