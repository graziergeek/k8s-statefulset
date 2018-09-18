# mongodb-simple Installation Instructions
Taken from an example in the book Kubernetes Up and Running.

**NOTE: I couldn't get this example to work** because the GKE node instances do not have the `ping` command (nor others) required by the MongoDB ConfigMap init script.
While it's possible to run `apt get` to install `ping`, I thought I'd look for a less hacky way to get a Mongo ReplicaSet running in K8s.

### To install, run:
`kubectl apply -f mongo-configmap.yaml`

`kubectl apply -f mongo-service.yaml`

`kubectl apply -f mongo-statefulset.yaml`

### To delete, run:

`kubectl delete configmap mongo-init`

`kubectl delete service mongo`

`kubectl delete statefulset mongo --cascade=false`

` for i in 0 1 2; do kubectl delete pod mongo-$i; done`

` for i in 0 1 2; do kubectl delete pvc mongodb-persistent-storage-claim-mongo-$i; done`


