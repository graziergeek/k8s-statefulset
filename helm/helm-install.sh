#!/usr/bin/env bash
# NOTE: We don't use tiller in this example. This script is only kept around for reference.
#
# Installs helm including cluster-side tiller.
# Expects a cluster up an running and current kube config pointing to it.
### NOTE: check to see if tiller is already running in the cluster *before* you run this script:
###     kubectl get pods -n kube-system
### if you see "tiller-deploy-*", no need to run this. You just need the client-side helm:
###     helm init --client-only
# See also, https://docs.helm.sh/helm/


kubectl -n kube-system create serviceaccount tiller
ACCOUNT=$(gcloud info --format='value(config.account)')
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller --user $ACCOUNT
helm init --service-account tiller --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}'
kubectl -n kube-system rollout status deployment tiller-deploy -w
