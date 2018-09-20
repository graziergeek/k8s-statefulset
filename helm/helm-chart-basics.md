## Get helm charts, customize values and install with kubectl (helm tiller is not needed)
See [how and why we don't use Tiller](https://blog.giantswarm.io/what-you-yaml-is-what-you-get)

See also, [Helm documentation](https://docs.helm.sh/helm/#helm)

### Infrastructure as code
When an application is configured and deployed into a cluster with these guidelines, the application's manifest that remain on disk are exact images of the application configured and running in the cluster.
These manifests can be committed to source control and so become a record of cluster configuration.

This is one of the first steps in achieving [Infrastructure as Code (IaC)](https://en.wikipedia.org/wiki/Infrastructure_as_Code) and Cloud Native Development. The steps we're doing here are very manual but follow-on work should include [CI/CD](https://medium.com/@nirespire/what-is-cicd-concepts-in-continuous-integration-and-deployment-4fe3f6625007) CI (automated building, testing, containerizing code that's committed to source control) and CD (automated deployment of built images using [Canary Deployment](https://octopus.com/docs/deployment-patterns/canary-deployments) or some similar methodology).

### Install Helm Client
See the [Helm Installation Guide](https://docs.helm.sh/using_helm/#installing-helm) for your particular OS.

We use Helm only for fetching charts and templating.  We deploy manifests with `kubectl`.
```
helm init --client-only
```
See [helm-install.sh](./helm-install.sh) if you need to install Helm Tiller.

### Add standard Helm repos
* Add the stable helm repo:
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```
* Add the incubator helm repo (if needed):
```
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
```

### To get the latest version of a helm chart,
Where `<chart-name>` is the name of the chart.  See https://github.com/helm/charts/tree/master/stable/redis-ha, for instance.  Where `redis-ha` is the chart name.

Fetches the chart and writes files to `<chart-name>` directory under the current directory.

(Note this repo URL is for helm stable)

```
helm fetch \
  --repo https://kubernetes-charts.storage.googleapis.com \
  --untar \
    <chart-name>
```

### (Optional) Change the values.yaml file to customize
**NOTE**: This example uses only default values. This set is left for reference only and can be skipped.
```
touch ./<chart-name>/specialization.yaml
```

Now edit `./<chart-name>/specialization.yaml` to override any settings in `./<chart-name>/values.yaml`.

Only add the settings you want to modify. Other settings will come from the original `values.yaml`.

### Run helm template to produce the customized chart manifests
Note: the `--values ...` argument is only needed if you customized any settings in `values.yaml`.  If not, `values.yaml` will be found and used by `helm template`.

The `<release-name>` will be the helm release name for the chart.
```
helm template \
  --name <release-name>
  --values ./<chart-name>/specialization.yaml \
  --output-dir ./manifests \
    ./<chart-name>
```
The helm release name will prefix the K8s resources created in the chart manifests.  That is, for a chart named `mongodb-replicaset`, for example, and a helm release name of, say, `stage`, the mongodb service will be named `stage-mongodb-replicaset`.

### Apply the new chart to the cluster with kubectl
```
kubectl apply --recursive --filename ./manifests/<chart-name>
```