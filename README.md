# Working with StatefulSets in K8s
This experimentation is a WIP...

Some things are GKE-specific.

* There's a [simple grails CRUD app](./grails-crud/README.md) that works on the MongoDB database.  More capabilities will be added to this as time goes on to test Elasticsearch, etc.

* All data sources are derived from Helm charts and live under the `./helm` directory.  See [helm-chart-basics](./helm/helm-chart-basics.md).
Here are the charts:
  * [MongoDB Replica Set](./helm/mongodb-replicaset/README.md)
  * [Elasticsearch](./helm/elasticsearch/README.md)
  * [Redis HA](./helm/redis-ha/README.md)
  * [Memcached](./helm/memcached/README.md)

# How to Create a K8s Cluster
### Prerequisites

Ensure the following dependencies are already fulfilled on your host Linux/Windows/Mac Workstation/Laptop:

1. An account has been registered with the Google Compute Platform (GCP). You can sign up to a [free trial](https://cloud.google.com/free/) for GCP. Note: The free trial places some restrictions on account resource quotas, in particular restricting storage to a maximum of 100GB.
2. GCP’s client command line tool [gcloud](https://cloud.google.com/sdk/docs/quickstarts) has been installed.
3. Your local workstation has been initialised to:
    1. use your GCP account,
    1. install the Kubernetes command tool (“kubectl”),
    1. configure authentication credentials, and
    1. set the default GCP zone to be deployed to:

    ```
    $ gcloud init
    $ gcloud components install kubectl
    $ gcloud auth application-default login
    $ gcloud config set compute/zone europe-west1-b
    ```

**Note:** To specify an alternative zone to deploy to, in the above command, you can first view the list of available zones by running the command: `$ gcloud compute zones list`

### Create Cluster
1. Make sure Kubernetes API is enabled in Google cloud console
1. To create a 3-node, auto-scaling (9 max) cluster, run:
    ```
    gcloud container clusters create css-sandbox \
      --zone=us-central1-a \
      --enable-autorepair \
      --enable-autoupgrade \
      --machine-type=n1-standard-2 \
      --enable-autoscaling --min-nodes=3 --max-nodes=9
    ```

### Deploy Applications
1. Deploy MongoDB, Elasticsearch, Redis HA, ...
    1. See [Helm manifests](./helm/helm-chart-basics.md)
1. Deploy App (this is for test app but steps are pretty much the same for any)
    1. In the [grails-crud](./grails-crud/README.md) test app...
    1. `./gradlew build`
    1. `./gradlew prepareDocker`
    1. `docker build -t grails-crud ./build/docker`
    1. `docker tag grails-crud gcr.io/<GCP-projectID>/grails-crud:1.4` (change the `image` name:version in k8s/grails-crud.yaml to match)
    1. `docker push gcr.io/<GCP-projectID>/grails-crud:1.4` (push image to GCR)
    1. `kubectl apply -f k8s/grails-crud.yaml` (deploy. pulls image from GCR.)
    1. `kubectl get pods` (should see something like):
    ```
    NAME                           READY     STATUS        RESTARTS   AGE
    grails-crud-666b6794c5-mgl8m   1/1       Running       0          6s
    mongo-0                        1/1       Running       0          1h
    mongo-1                        1/1       Running       0          1h
    mongo-2                        1/1       Running       0          1h
    ```
    1. See [grails-crud](./grails-crud/README.md) for K8s testing.

## Creating a GCP Account Token (Optional)
This step is not needed for this example.

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
