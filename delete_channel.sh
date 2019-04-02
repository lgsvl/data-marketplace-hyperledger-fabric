
KUBECONFIG_FOLDER=${PWD}/configFiles

kubectl delete -f ${KUBECONFIG_FOLDER}/join_channel.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/create_channel.yaml


sleep 15

echo -e "\njobs:"
kubectl get jobs 
echo -e "\ndeployments:"
kubectl get deployments
echo -e "\npods:"
kubectl get pods


