
KUBECONFIG_FOLDER=${PWD}/configFiles

kubectl delete -f ${KUBECONFIG_FOLDER}/join_channel.yaml -n dev
kubectl delete -f ${KUBECONFIG_FOLDER}/create_channel.yaml -n dev


sleep 15

echo -e "\njobs:"
kubectl get jobs  -n dev
echo -e "\ndeployments:"
kubectl get deployments -n dev
echo -e "\npods:"
kubectl get pods -n dev


