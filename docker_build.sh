#!/bin/bash

if [ ! "$#" -gt 0 ]; then 
    echo "Usage: docker_build.sh <name> [tag]"
    exit 1
fi

DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
IMAGE="$1"
CONTAINER_NAME="$1"

if [[ -n $(docker ps -a --filter name="$CONTAINER_NAME" --format "{{.Names}}") ]]; then
    echo "[x] The image is being used by a container!"
    exit 1
fi

if [[ -z $2 ]]; then
    TAG=latest
else
    TAG=$2
fi

# cp ~/.cargo/config.toml "$DIR/config.toml"

echo "[*] Building image $IMAGE:$TAG"
docker buildx build --network=host -t "$IMAGE:$TAG" "$DIR" \
    --build-arg "HTTP_PROXY=$PROXY_ADDRESS" \
    --build-arg "HTTPS_PROXY=$PROXY_ADDRESS" \
    --build-arg "http_proxy=$PROXY_ADDRESS" \
    --build-arg "https_proxy=$PROXY_ADDRESS"