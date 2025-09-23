#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Usage: run.sh <image name>"
    exit 1
fi

IMAGE="$1:latest"
CONTAINER_NAME="$1"
DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
HOST_SHMEM_SIZE=$(df -h /dev/shm | tail -1 | awk '{print $2}')

RUN_FLAGS="
-id \
--name $CONTAINER_NAME \
--network host \
--security-opt seccomp=unconfined \
--cap-add=SYS_PTRACE \
--mount type=bind,src=$DIR/circt,dst=/home/user/circt \
--mount type=bind,src=$DIR/workspace,dst=/home/user/workspace \
--shm-size=$HOST_SHMEM_SIZE \
--ulimit msgqueue=2097152000 \
"

run_docker() {
    docker run $RUN_FLAGS $IMAGE
}

if [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --format "{{.Names}}") ]]; then
    # container exists, check status
    if [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --filter status=running --format "{{.Names}}") ]]; then
        # running, do nothing
        :
    elif [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --filter status=created --format "{{.Names}}") ]]; then
        # created, never running, run it
        run_docker
    elif [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --filter status=paused --format "{{.Names}}") ]]; then
        # paused, unpause it
        docker unpause $CONTAINER_NAME
    elif [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --filter status=exited --format "{{.Names}}") ]]; then
        # exited, restart
        docker start $CONTAINER_NAME
    elif [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --filter status=dead --format "{{.Names}}") ]]; then
        # dead, remove it then run a new one
        docker rm $CONTAINER_NAME
        run_docker
    elif [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --filter status=restarting --format "{{.Names}}") ]]; then
        echo "[*] The container is restarting, please try later!"
    elif [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --filter status=removing --format "{{.Names}}") ]]; then
        echo "[*] The container is being removed, please try later!"
    fi
else
    run_docker
fi

if [[ -n $(docker ps -a --filter name=$CONTAINER_NAME --format "{{.Names}}") ]]; then
    docker exec -it $CONTAINER_NAME bash
else
    echo "[x] Failed to run container :("
fi