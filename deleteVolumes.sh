KUBECONFIG_FOLDER=${PWD}/configFiles

kubectl delete -f ${KUBECONFIG_FOLDER}/createVolume.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/createCouchDBVolume.yaml

sleep 10

echo -e "\npv:" 
kubectl get pv
echo -e "\npvc:"
kubectl get pvc