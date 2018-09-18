#!/usr/bin/env bash
# Quick and dirty cleanup of resources in a k8s cluster -WIP

load_balancer_exists() {
  kubectl get svc --all-namespaces | grep "LoadBalancer" > /dev/null 2>&1
}

namespace_exists() {
    kubectl get namespace $1 > /dev/null 2>&1
}

volume_claim_exists() {
    kubectl get pvc --all-namespaces -o jsonpath='{.items[0]}' > /dev/null 2>&1
}

volume_claims_delete() {
    NAMESPACES=`kubectl get ns | awk '{ if (NR != 1 && $1 !~ /(kube-)/ ) print $1}'`
    for ns in $NAMESPACES; do
        PVCs=`kubectl get pvc  -n ${ns} -o jsonpath='{.items[*].metadata.name}' 2> /dev/null`
        # echo "PVCs: ${ns} - $PVCs"
        if [ ! -z "$PVCs" ]; then
            for pvc in ${PVCs}; do
                 echo "Deleting volume claim ${pvc} in namespade ${ns}..."
                kubectl delete pvc -n ${ns} ${pvc}
            done
        fi
    done
}

# GCP-specific. Not used.
delete_gcp_service_account() {
    serviceaccount_name=${CLUSTER_NAME}-${1}@${GOOGLE_PROJECT}.iam.gserviceaccount.com
    gcloud iam service-accounts describe ${serviceaccount_name} > /dev/null 2>&1
    if [ "$?" = "0" ];
    then
        gcloud iam service-accounts delete --quiet ${serviceaccount_name}

        gcloud --quiet projects remove-iam-policy-binding ${GOOGLE_PROJECT} \
               --member=serviceAccount:${serviceaccount_name} \
               --role="${2}"
    fi
}

# Delete ingresses and services
NAMESPACES=`kubectl get ns | awk '{ if (NR != 1 && $1 !~ /(kube-)/ ) print $1}'`
for ns in $NAMESPACES; do
  for resource in ingress service; do
    RESOURCES=`kubectl get -n $ns $resource 2> /dev/null | awk '{ if (NR != 1) print $1}'`
    if [ ! -z "$RESOURCES" ]; then
      kubectl -n $ns delete $resource $RESOURCES
    fi
  done
done

# Persistent Volume Claims specifically. Volumes should be garbage collected after zero claims.
PROG_BACKOFF=0
while volume_claim_exists && [ "${PROG_BACKOFF}" -le "4" ]; do
    echo "Deleting volume claims..."
    volume_claims_delete
    echo "Waiting for volume claims to be deleted... $PROG_BACKOFF"
    sleep $(( PROG_BACKOFF++ ))
done
if volume_claim_exists ; then
    echo "Not all volume claims could be deleted!"
fi

# LoadBalancers are stubborn sometimes, wait...
PROG_BACKOFF=0
while load_balancer_exists && [ "${PROG_BACKOFF}" -le "4" ]; do
    echo "Waiting for load balancers to die... $PROG_BACKOFF"
    sleep $(( PROG_BACKOFF++ ))
done
if load_balancer_exists ; then
    echo "Not all load balancers could be deleted!"
fi

# Delete all NameSpaces except "kube-*" and "default".
NAMESPACES=`kubectl get ns | awk '{ if (NR != 1 && $1 !~ /(kube-|default)/ ) print $1}'`
for ns in ${NAMESPACES/infra/}; do
    if namespace_exists ${ns}; then
        echo "Deleting namespace ${ns}..."
        kubectl delete namespace ${ns}
    fi
done
