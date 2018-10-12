

# Grails - MongoDB CRUD App
[This example came from here](https://www.djamware.com/post/5a6dd5c680aca7059c142977/grails-3-mongodb-and-rest-api-profile-crud-application)

## Requires
* Docker
* Grails Version: 3.3.7 (installed with homebrew)

---

### TODO: auto-test with docker compose

# Dockerize and Run on k8s
### Build, Congtainerize and Deploy App
1. `export GCP_PROJECT_ID=<your-gcp-project-id>` (point to your GCP project id)
1. `./gradlew clean assemble`
1. `docker build -t grails-crud .`
1. `docker tag grails-crud gcr.io/${GCP_PROJECT_ID}/grails-crud:1.5` (change the `image` name:version in grails-crud.yaml to match)
1. `docker push gcr.io/${GCP_PROJECT_ID}/grails-crud:1.5` (push image to GCR)
1. `kubectl apply -f k8s/grails-crud.yaml` (deploy. pulls image from GCR.)
1. `kubectl get pods` (should see something like:)
```
NAME                           READY     STATUS        RESTARTS   AGE
grails-crud-666b6794c5-mgl8m   1/1       Running       0          6s
mongo-0                        1/1       Running       0          1h
mongo-1                        1/1       Running       0          1h
mongo-2                        1/1       Running       0          1h
```

### Get env from K8s:
`export HOST=$(kubectl get service grails-crud -o jsonpath='{.status.loadBalancer.ingress[0].ip}')`

`export PORT=$(kubectl get service grails-crud -o jsonpath='{.spec.ports[?(@.protocol=="TCP")].port}')`

`export HOST_PORT=$HOST:$PORT`

### Make sure app is accessible
(should see grails app config JSON)

`curl -i -H "Accept: application/json" http://${HOST_PORT}`

### Make sure app can access MongoDB
(should see only `[]`, since there's no data in mongo yet.)

`curl -i -H "Accept: application/json" http://${HOST_PORT}/board`

### insert
`curl -i -X POST -H "Content-Type: application/json" -d '{"title":"Register For Class","description":"Students must register for class.","location":"Registrar office","eventDate":"08/02/18 00:00"}' http://${HOST_PORT}/board`

`curl -i -X POST -H "Content-Type: application/json" -d '{"title":"Mid Term Break","description":"Mid term break for all students","location":"outta here","eventDate":"11/07/18 00:00"}' http://${HOST_PORT}/board`

`curl -i -X POST -H "Content-Type: application/json" -d '{"title":"Annual Holiday","description":"Annual holiday for all students","location":"none","eventDate":"01/02/18 00:00"}' http://${HOST_PORT}/board`

### update
  `curl -i -X PUT -H "Content-Type: application/json" -d '{"title":"Independence Day Holiday"}' localhost:8080/board/1`
#### Check in browser: http://localhost:8080/board

### To delete from K8s, run:
`kubectl delete -f k8s/grails-crud.yaml`


## Create docker-compose.yaml in project root to run both `grails-crud` and `mongodb` containers in same VM.

### Build and run Docker compose
  `docker-compose build`

  `docker-compose up`
#### exec curl cmds as [insert](#insert), [update](#update), etc. above...
  `docker-compose stop && docker-compose rm -vf`
