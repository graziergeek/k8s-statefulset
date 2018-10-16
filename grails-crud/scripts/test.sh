#!/usr/bin/env bash

export HOST=$(kubectl get service grails-crud -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export PORT=$(kubectl get service grails-crud -o jsonpath='{.spec.ports[?(@.protocol=="TCP")].port}')
export HOST_PORT=$HOST:$PORT

echo "Writing to grails-crud at $HOST_PORT"

curl -i -X POST -H "Content-Type: application/json" -d '{"title":"EveryDay is a Holiday","description":"Let us party!","location":"none","eventDate":"10/11/18 00:00"}' http://${HOST_PORT}/board

curl -i -H "Accept: application/json" http://${HOST_PORT}/board

for i in `seq 1 20`; do curl -i -X POST -H "Content-Type: application/json" -d '{"title":"EveryDay is a Holiday","description":"Let us party!","location":"none","eventDate":"10/11/18 00:00"}' http://${HOST_PORT}/board; done
