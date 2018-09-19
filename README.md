# Working with StatefulSets in K8s
This experimentation is a WIP...

Some things are GKE-specific.

1. There's a [simple grails CRUD app](./grails-crud/README.md) that works on the MongoDB database.  More capabilities will be added to this as time goes on to test Elasticsearch, etc.

1. All data sources are derived from Helm charts and live under the `./helm` directory.  See [helm-chart-basics](./helm/helm-chart-basics.md)

# How to Create a K8s Cluster

1. See also [K8s prerequisites](https://github.com/graziergeek/gke-mongodb-demo/tree/432ac4402e5ee769359b97f17dc155042f0d8268#11-prerequisites) in the `gke-mongodb-demo` `README` file.
1. (Optional) [Create GCP Admin Service Account and Download Key](#creating-a-gcp-account-token)
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
1. Deploy MongoDB, Elasticsearch, Redis HA, ...
    1. See [Helm manifests](./helm/helm-chart-basices.md)
1. Deploy App (this is for test app but steps are pretty much the same)
    1. In the [grails-crud](./grails-crud/README.md) test app...
    1. `./gradlew build`
    1. `./gradlew prepareDocker`
    1. `docker build -t grails-crud ./build/docker`
    1. `docker tag grails-crud gcr.io/<GCP-projectID>/grails-crud:1.4` (change the `image` name:version in grails-crud.yaml to match)
    1. `docker push gcr.io/<GCP-projectID>/grails-crud:1.4` (push image to GCR)
    1. `kubectl apply -f k8s/grails-crud.yaml` (deploy. pulls image from GCR.)
    1. `kubectl get pods` (should see something like:)
```
NAME                           READY     STATUS        RESTARTS   AGE
grails-crud-666b6794c5-mgl8m   1/1       Running       0          6s
mongo-0                        1/1       Running       0          1h
mongo-1                        1/1       Running       0          1h
mongo-2                        1/1       Running       0          1h
```

## Creating a GCP Account Token (Optional)
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

To create and download a gcloud private key file if you DO already have a service account:

1. Go to the [Google Cloud Platform / IAM & admin / Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) page.

1. Choose your service account by selecting the ellipses (three dots) on its right.

1. Select `Create Key`

1. Leave Key type as JSON

1. Select `Create`

1. The key is downloaded to your computer.

1. Store the key file in a safe and accessible place.  **Do not check it in to source control**.
    1. e.g., `${HOME}/.k8sconfig/<name>.json`.
