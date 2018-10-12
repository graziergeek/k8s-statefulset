FROM openjdk:8u151-jdk-alpine
MAINTAINER John Doe "john.doe@example.com"

EXPOSE 8080

# will be overwritten by k8s mongodb configmap
ENV MONGODB_HOST=mongo

WORKDIR /app
COPY ./build/libs/*.jar application.jar

CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app/application.jar"]

