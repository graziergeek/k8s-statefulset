## Get helm charts, customize values and install with kubectl (helm tiller not needed)
See also, [helm-install.sh](./helm-install.sh) if you need to install helm (use --client-only option).

See also, [Helm documentation](https://docs.helm.sh/helm/#helm)

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
Where `<chart-name>` is the name of the chart.  See https://github.com/helm/charts/tree/master/stable/redis-ha, for instance.  `redis-ha` is the chart name.

Fetches the chart and writes files to `<chart-name>` directory under the current directory.

(Note this repo URL is for helm stable)

```
helm fetch \
  --repo https://kubernetes-charts.storage.googleapis.com \
  --untar \
    <chart-name>
```

### Change the values.yaml file to customize
```
touch ./<chart-name>/specialization.yaml`
```

Now edit `./<chart-name>/specialization.yaml` to override any settings in `./<chart-name>/values.yaml`.

Only add the settings you want to modify. Other settings will come from the original `values.yaml`.

### Run helm template to produce the customized chart manifests
Note: the `--values ...` is only needed if you customized any settings in `values.yaml`.  If not, `values.yaml` will be found and used by `helm template`.

```
helm template \
  --values ./<chart-name>/specialization.yaml \
  --output-dir ./manifests \
    ./<chart-name>
```

### Apply the new chart to the cluster with kubectl
```
kubectl apply --recursive --filename ./manifests/<chart-name>
```