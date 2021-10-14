This image is used as a managed node.

# Build & Push
docker build -t irixjp/katacoda:centos8-node .
docker login
docker push irixjp/katacoda:centos8-node
