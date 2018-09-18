# Working with StatefulSets in K8s
This experimentation is a WIP...

1. There's a [simple grails CRUD app](./grails-crud/README.md) that works on the MongoDB database.  More capabilities will be added to this as time goes on.

1. There's a [simple MongoDB-ReplicaSet K8s installation](./mongodb-simple/README.md) that I scarfed from the book _Kubernetes Up and Running_ that failed to work.

1. There's a more "enterprise-ready" [MongoDB HA installation](./gke-mongodb-demo/README.md) that I found in [Paul Done's](https://github.com/pkdone) gitub repo that I'm working with now.

1. There will be an [ElasticSearch project](./gke-elasticsearch-demo/README.md) that will show how to work with StatefulSets for ElasticSearch.

# How to Create a K8s Cluster

1. See also [K8s prerequisites](./gke-mongodb-demo/README.md#1.1_prerequisites) in the `gke-mongodb-demo` `README` file.
1. [Create GCP Admin Service Account and Download Key](#creating-a-gcp-account-token)
1. Make sure Kubernetes API is enabled in cloud console
1. run:
```
gcloud container clusters create css-sandbox \
  --zone=us-central1-a \
  --enable-autorepair \
  --enable-autoupgrade \
  --machine-type=n1-standard-2 \
  --enable-autoscaling --min-nodes=3 --max-nodes=9
```
1. Deploy MongoDB
    1. ..._working on this..._
1. Deploy App (this is for test app but steps are pretty much the same)
    1. In the [grails-crud](./grails-crud/README.md) test app...
    1. `./gradlew build`
    1. `./gradlew prepareDocker` (?)
    1. `docker build -t grails-crud ./build/docker`
    1. `docker tag grails-crud gcr.io/cunningham-sandbox/grails-crud:1.2` (match the `image` name:version in grails-crud.yaml)
    1. `docker push gcr.io/cunningham-sandbox/grails-crud:1.2` (push image to GCR)
    1. `kubectl apply -f k8s/grails-crud.yaml` (deploy. pulls image from GCR.)
    1. `kubectl get pods` (should see something like:)
```
NAME                           READY     STATUS        RESTARTS   AGE
grails-crud-666b6794c5-mgl8m   1/1       Running       0          6s
mongo-0                        1/1       Running       0          1h
mongo-1                        1/1       Running       0          1h
mongo-2                        1/1       Running       0          1h
```

## Creating a GCP Account Token
Whenever downloading a private key, put it in a safe place.  By all means do **NOT** add it to source control.

To create and download a gcloud private key file if you DON'T already have a service account:

1. Go to the [Google Cloud Platform / IAM & admin / Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) page.

1. Choose `+ Create Service Account`

1. In the resulting dialog, give it a name (for example, `<project-name>-admin-service-account`)

1. Leave the `Service account ID`

1. Select the required roles for creating and modifying a Kubernetes cluster:
    1. Compute Engine / Compute Admin
    1. Kubernetes Engine / Kubernetes Engine Admin
    1. Storage / Storage Admin
    1. Service Accounts / Service Account User

1. Check the box that says `Furnish a new private key`

1. Select `Create`

1. The key is downloaded to your computer.

1. Store the key file in a safe and accessible place.  **Do not check it in to source control**.
    1. In the create cluster examples, we store the key file under `${HOME}/.k8sconfig/<name>.json`.  The host volume file name doesn't matter as long as the environment file name is specified as `account.json`.

To create and download a gcloud private key file if you DO already have a service account:

1. Go to the [Google Cloud Platform / IAM & admin / Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) page.

1. Choose your service account by selecting the ellipses (three dots) on its right.

1. Select `Create Key`

1. Leave Key type as JSON

1. Select `Create`

1. The key is downloaded to your computer.

1. Store the key file in a safe and accessible place.  **Do not check it in to source control**.
    1. In the create cluster examples, we store the key file under `${HOME}/.k8sconfig/<name>.json`.  The host volume file name doesn't matter as long as the environment file name is specified as `account.json`.