KUBECONFIG_FOLDER=${PWD}/configFiles

kubectl delete -f ${KUBECONFIG_FOLDER}/createVolume.yaml -n dev
kubectl delete -f ${KUBECONFIG_FOLDER}/createCouchDBVolume.yaml -n dev

sleep 10

echo -e "\npv:" 
kubectl get pv
echo -e "\npvc:"
kubectl get pvc -n dev