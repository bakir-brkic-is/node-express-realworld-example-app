# Node Express Realworld Example

[Default Readme file of this project is here.](README.default.md)

## This is a guide and overview of changes and additions to the project.

## Additions and changes:
- Made it possible to build the app and package it inside Docker image, 3 Docker files are provided, based on following base images:
    - [node:lts](https://hub.docker.com/_/node)
    - [node:alpine](https://hub.docker.com/_/node)
    - gcr.io/distroless/nodejs - Googles distroless images (for Node.js)
- Jenkinsfile containing build pipeline
- Made it possible to deploy the app to Kubernetes clusters by creating objects definitions
- Created Terraform file that provisions EKS cluster and required resources on AWS
## How to:
- Set it up in Jenkins: 
    - Pipeline in [Jenkinsfile](Jenkinsfile)
- By changing environment directive in Jenkinsfile it is possible to set:
    - MONGODB_URI
    - SECRET
    - MONGO_INITDB_ROOT_PASSWORD
    - PORT (on which express listens)
- Pushing to image repository should be done manualy (select where do you want to push it docker hub / AWS ECR / other)
- Change the *expressbackend-deployment.yml* to reflect the location from whic the image should be pulled 

Jenkins build agent images:
- brrx387/jenkins-docker
- node:lts

## More detailed description of changes and additions:
- Create multistage Dockerfile that will contain the API service
    - simple comparisson between different approaches was done to find out how to make the smallest possible image by utilizing multi-stage docker build.
    - Repository contains 3 Docker files, that build images based on node, alpine, and google’s distroless node base image
        - REPOSITORY : SIZE 
        - expressbackend-distroless : 67.7MB
        - expressbackend-alpine : 158MB 
        - expressbackend : 953MB
- Create Kubernetes object definitions (Deployment, ConfigMap, Secret and Service) for API service. 
    - Deployment for express
    - Config map for express
    - Secret for mongodb
    - Service for express
- Use kustomize for staging/production separation (add a small change in production, like increase replica count or change container limits).
- Deploy mongodb using either Helm or statefulset/deployment. (If using helm for mongodb installation, commit values.yaml file)
    - installed using helm, used default values.yml just edited the section where it is possible to provide existing secret and plugedin “mongo-secret”