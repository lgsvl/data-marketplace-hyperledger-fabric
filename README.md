# Data Marketplace on top of Hyperledger Fabric
Notice: This document is heavily inspired from [an IBM tutorial](https://github.com/IBM/blockchain-network-on-kubernetes#4-deploy-hyperledger-fabric-network-into-kubernetes-cluster)
You need to have the [data marketplace chaincode](https://github.com/lgsvl/data-marketplace-chaincode) correctly setup in your Go Path.

# Deploy the Blockchain network using Kubernetes APIs on IBM Cloud

Blockchain is a shared, immutable ledger for recording the history of transactions. For developing any blockchain use-case, the very first thing is to have a development environment for Hyperledger Fabric to create and deploy the application. Hyperledger Fabric network can be setup in multiple ways. 
* [Hyperledger Fabric network On-Premise](http://hyperledger-fabric.readthedocs.io/en/release-1.0/build_network.html)
* Using [Blockchain as a service](https://console.bluemix.net/catalog/services/blockchain) hosted on [IBM Cloud](https://console.bluemix.net/). IBM Cloud provides you Blockchain as a service with a Starter Membership Plan and Enterprise Membership Plan.
* Hyperledger Fabric network using [Kubernetes APIs]((https://console.bluemix.net/containers-kubernetes/catalog/cluster)) on [IBM Cloud Container Service](https://console.bluemix.net/containers-kubernetes/catalog/cluster)

In this repository we suppose that you have a running kubernetes cluster and a well configured Kubectl.
This code pattern demonstrates the steps involved in setting up a data marketplace chaincode on Hyperledger on **Hyperledger Fabric using Kubernetes APIs**. 

In our case, we used EKS as a Kubernetes instance with EFS for the persistent volumes.


## Included components

* [Hyperledger Fabric](https://hyperledger-fabric.readthedocs.io/): Hyperledger Fabric is a platform for distributed ledger solutions underpinned by a modular architecture delivering high degrees of confidentiality, resiliency, flexibility and scalability.

* [IBM Cloud Container Service](https://console.bluemix.net/containers-kubernetes/catalog/cluster): IBM Container Service enables the orchestration of intelligent scheduling, self-healing, and horizontal scaling.

## Featured technologies

* [Blockchain](https://en.wikipedia.org/wiki/Blockchain): A blockchain is a digitized, decentralized, public ledger of all transactions in a network.

* [Kubernetes Cluster](https://kubernetes.io/docs): In Kubernetes Engine, a container cluster consists of at least one cluster master and multiple worker machines called nodes. A container cluster is the foundation of Kubernetes Engine.


## Kubernetes Concepts Used
* [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/) - Pods represent the smallest deployable units in a Kubernetes cluster and are used to group containers that must be treated as a single unit.
* [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) - A job creates one or more pods and ensures that a specified number of them successfully terminate. As pods successfully complete, the job tracks the successful completions.
* [Kubernetes Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) - A deployment is a Kubernetes resource where you specify your containers and other Kubernetes resources that are required to run your app, such as persistent storage, services, or annotations.
* [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/) - A Kubernetes service groups a set of pods and provides network connection to these pods for other services in the cluster without exposing the actual private IP address of each pod.
* [Kubernetes Persistent Volumes (PV)](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) - PersistentVolumes are a way for users to *claim* durable storage such as NFS file storage.

## Steps

Follow these steps to setup and run this code pattern:

### Deploy Hyperledger Fabric Network into Kubernetes Cluster

#### Understand the network topology

This pattern provides a script which automatically provisions a sample Hyperledger Fabric network consisting of two organizations, each maintaining one peer node, and a 'solo' ordering service. Also, the script creates a channel named as `dmp`, joins all peers to the channel `dmp`, install chaincode on all peers and instantiate chaincode on the channel.

#### Copy Kubernetes configuration scripts

Clone or download the Kubernetes configuration scripts to your user home directory.
  ```
  $ git clone https://github.com/lgsvl/data-marketplace-hyperledger-fabric.git
  ```

Navigate to the source directory
  ```
  $ cd data-marketplace-hyperledger-fabric
  $ ls
  ```
In the source directory, 
  * `configFiles` contains Kubernetes configuration files
  * `artifacts` contains the network configuration files
  * `*.sh` scripts to deploy and delete the network
  
#### Modify the Kubernetes configuration scripts

If there is any change in network topology, need to modify the configuration files (.yaml files) appropriately. The configuration files are located in `artifacts` and `configFiles` directory. For example, if you decide to increase/decrease the capacity of persistant volume then you need to modify `createVolume.yaml`. You can also modify the storage class being used, in our case we used EFS (this requires to setup the dynamic provisioner of Amazon EFS on your Kubernetes cluster). 

#### Run the script to deploy your Hyperledger Fabric Network

Once you have completed the changes (if any) in configuration files, you are ready to deploy your network. Execute the scripts to deploy your hyperledger fabric network.
You migh need to add execution permissions to the scripts.

  ```
  $ ./create_dev_Volumes.sh # This will create 1 shared volume to host the configuration and artifacts and two volumes for couchDB for each organization 
  $ ./setup_dev_blockchainNetwork.sh # This will create the network and start the organization peers
  $ ./setup_dev_channel.sh # This will create the channel and make the peers join it
  $ ./setup_dev_chaincode.sh # This will deploy the chaincode to of the data markeplace to the fabric network
  ```

Note: Before running the script, please check your environment. You should able to run `kubectl commands` properly with your cluster. 

#### Delete the network

If required, you can bring your hyperledger fabric network down using the different delete scripts ( e.g., `delete_dev_blockchainNetwork.sh`. These scripts will delete all your pods, jobs, deployments etc. from your Kubernetes cluster.

  ```
  $ ./delete_dev_channel.sh # This will delete the channel
  $ ./delete_dev_blockchainNetwork.sh # This will delete the network
  $ ./delete_dev_Volumes.sh # This will delete the volumes
  ```

### 5. Test the deployed network

After successful execution of the script `setup_blockchainNetwork.sh`, check the status of pods.

  ```
  $ kubectl get pods
  NAME                                    READY     STATUS    RESTARTS   AGE
  blockchain-ca-7848c48d64-2cxr5          1/1       Running   0          4m
  blockchain-orderer-596ccc458f-thdgn     1/1       Running   0          4m
  blockchain-org1peer1-747d6bdff4-4kzts   1/1       Running   0          4m
  blockchain-org2peer1-7794d9b8c5-sn2qf   1/1       Running   0          4m
  ```

As mentioned above, the script joins all peers on one channel `dmp`, install chaincode on all peers and instantiate chaincode on the channel. It means we can execute an invoke/query command on any peer and the response should be same on all peers. Please note that in this pattern tls certs are disabled to avoid complexity. In this pattern, the CLI commands are used to test the network. For running a query against any peer, need to get into a bash shell of a peer, run the query and exit from the peer container. You can also use the [data marketplace REST API] 

Use the following command to get into a bash shell of a peer:

  ```
  $ kubectl exec -it <blockchain-org1peer1 pod name> bash
  ```
You can use the example in [testScript](./testScript.txt) to create accounts and make transfers. The initial token created with a total amount of 10000 tokens.

And the command to be used to exit from the peer container is:

  ```
  # exit
  ```


## Reference Links

* [Hyperledger Fabric](https://hyperledger-fabric.readthedocs.io/en/release-1.1/)
* [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)

## License

[Apache 2.0](LICENSE)
