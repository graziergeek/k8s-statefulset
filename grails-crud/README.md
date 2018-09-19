

# Grails - MongoDB CRUD App
[see where this example came from](https://www.djamware.com/post/5a6dd5c680aca7059c142977/grails-3-mongodb-and-rest-api-profile-crud-application)

This has already been done in this project.  Here's what happened:

## Requires
* Docker
* Grails Version: 3.3.7 (installed with homebrew)
* (optional) MongoDB v3.4.17 (installed with homebrew)
  * (**NOTE**: to skip installation of MongoDB, follow grails project instructions, don't start `mongod` and jump to [Dockerize](#Dockerize).)
  * `echo 'export PATH="/usr/local/opt/mongodb@3.4/bin:$PATH"' >> ~/.bash_profile`
  * To start: `mongod --config /usr/local/etc/mongod.conf &`

---
# Create grails project and run with mongo on bare OS
  `grails create-app grails-crud --profile=rest-api --features=mongodb`
  
  `cd grails-crud`
### Enter grails project env by running:
  `grails`

  `run-app`

  `create-domain-class grails.rest.Board`

### edit `grails-app/domain/grails/restBoard.groovy`, to contain:
```
package grails.rest

import grails.databinding.BindingFormat

class Board {

  String title
  String description
  String location
  @BindingFormat('dd/MM/yy HH:mm')
  Date eventDate

  static constraints = {
  }
}
```
  `create-restful-controller grails.rest.Board`

### Start mongod in bg
`mongod --config /usr/local/etc/mongod.conf &`

### Hit the app to query items (noting in there yet)
  `curl -i -H "Accept: application/json" localhost:8080/board`
### insert
  `curl -i -X POST -H "Content-Type: application/json" -d '{"title":"Annual Holiday","description":"Annual holiday for all students","location":"none","eventDate":"01/02/18 00:00"}' localhost:8080/board`
### get data
  `curl -i -H "Accept: application/json" localhost:8080/board`
#### or 
  `curl -i -H "Accept: application/json" localhost:8080/board/1`
### update
  `curl -i -X PUT -H "Content-Type: application/json" -d '{"title":"Independence Day Holiday"}' localhost:8080/board/1`
#### Check in browser: http://localhost:8080/board
### delete
  `curl -i -X DELETE localhost:8080/board/1`

### TODO: auto-test with docker compose

# Dockerize
[see item 5 in this doc](http://guides.grails.org/grails-as-docker-container/guide/#usingOnlyDocker)

Create docker-compose.yaml in project root to run both `grails-crud` and `mongodb` containers in same VM.

## Build and run Docker compose
  `docker-compose build`

  `docker-compose up`
#### exec curl cmds as [insert](#insert), [update](#update), etc. above...
  `docker-compose stop && docker-compose rm -vf`

# Run on k8s
### Deploy App
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

#### Get env from K8s:
`export HOST=$(kubectl get service grails-crud -o jsonpath='{.status.loadBalancer.ingress[0].ip}')`

`export PORT=$(kubectl get service grails-crud -o jsonpath='{.spec.ports[?(@.protocol=="TCP")].port}')`

`export HOST_PORT=$HOST:$PORT`

#### Make sure app is accessible
(should see grails app config JSON)

`curl -i -H "Accept: application/json" http://${HOST_PORT}`

#### Make sure app can access MongoDB
(should see only `[]`, since there's no data in mongo yet.)

`curl -i -H "Accept: application/json" http://${HOST_PORT}/board`

#### Good?  Then add data and query again
(see [insert](#insert), [update](#update), etc. above...

`curl -i -X POST -H "Content-Type: application/json" -d '{"title":"Register For Class","description":"Students must register for class.","location":"Registrar office","eventDate":"08/02/18 00:00"}' http://${HOST_PORT}/board`

`curl -i -X POST -H "Content-Type: application/json" -d '{"title":"Mid Term Break","description":"Mid term break for all students","location":"outta here","eventDate":"11/07/18 00:00"}' http://${HOST_PORT}/board`

`curl -i -X POST -H "Content-Type: application/json" -d '{"title":"Annual Holiday","description":"Annual holiday for all students","location":"none","eventDate":"01/02/18 00:00"}' http://${HOST_PORT}/board`

## To delete from K8s, run:
`kubectl delete -f k8s/grails-crud.yaml`